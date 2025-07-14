`timescale 1ns / 1ps

// ===================================================================
// == Data Mover (Top Module with Kernel)                          ==
// ===================================================================
module data_mover #(
    // Parameters for data mover and kernel
    parameter KW      = 5,
    parameter KH      = 5,
    parameter IF_BW   = 8,
    parameter W_BW    = 8,
    parameter BRAM_BW = 32
)(
    // System Signals
    input wire                      clk,
    input wire                      rst, // Active-high reset

    // Control & BRAM Interface
    input wire                      i_start,
    input wire [31:0]               i_bram_base_addr,
    input wire [BRAM_BW-1:0]        i_bram_rdata,
    output reg [31:0]               o_bram_addr,
    output reg                      o_bram_re,

    // Weight input for the internal Kernel
    input wire [KW*KH*W_BW-1:0]     i_kernel_weight,

    // Final Output from the internal Kernel
    output wire [16 + $clog2(KW*KH)-1:0] o_final_result,
    output wire                         o_final_valid
);
    // -- Internal Signals & Registers for Data Mover Logic --
    localparam IFMAP_WIDTH = KW * KH * IF_BW;
    localparam NUM_READS   = (IFMAP_WIDTH + BRAM_BW - 1) / BRAM_BW;

    // FSM States
    localparam S_IDLE = 2'b00;
    localparam S_READ = 2'b01;
    localparam S_DONE = 2'b10;

    // Internal Registers
    reg [1:0]   state_reg, next_state;
    reg [$clog2(NUM_READS)-1:0] read_cnt_reg;
    reg [IFMAP_WIDTH-1:0]       ifmap_reg; // Holds the assembled ifmap data

    // Wire to trigger the kernel
    wire kernel_start_valid;
    wire rst_n = ~rst;

    // -- Data Mover FSM and Logic --

    // FSM Sequential Logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) state_reg <= S_IDLE;
        else        state_reg <= next_state;
    end

    // FSM Combinational Logic
    always @(*) begin
        next_state  = state_reg;
        o_bram_addr = 0;
        o_bram_re   = 1'b0;

        case (state_reg)
            S_IDLE: begin
                if (i_start) begin
                    o_bram_addr = i_bram_base_addr;
                    next_state  = S_READ;
                end
            end
            S_READ: begin
                o_bram_re   = 1'b1;
                o_bram_addr = i_bram_base_addr + read_cnt_reg;
                if (read_cnt_reg == NUM_READS-1) next_state = S_DONE;
                else                             next_state = S_READ;
            end
            S_DONE: begin
                // Data is ready, will trigger kernel in this cycle.
                // Move back to IDLE on the next cycle.
                next_state = S_IDLE;
            end
            default: next_state = S_IDLE;
        endcase
    end
    
    // Assign kernel trigger signal
    assign kernel_start_valid = (state_reg == S_DONE);

    // Data Assembling and Counter Logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            read_cnt_reg <= 0;
            ifmap_reg    <= 0;
        end else begin
            if (state_reg == S_IDLE && next_state == S_READ) begin
                read_cnt_reg <= 0;
            end else if (state_reg == S_READ) begin
                read_cnt_reg <= read_cnt_reg + 1;
                // Assemble the data from BRAM into ifmap_reg
                // A case statement is often clearer here
                case (read_cnt_reg)
                    3'd0: ifmap_reg[31:0]     <= i_bram_rdata;
                    3'd1: ifmap_reg[63:32]    <= i_bram_rdata;
                    3'd2: ifmap_reg[95:64]    <= i_bram_rdata;
                    3'd3: ifmap_reg[127:96]   <= i_bram_rdata;
                    3'd4: ifmap_reg[159:128]  <= i_bram_rdata;
                    3'd5: ifmap_reg[191:160]  <= i_bram_rdata;
                    3'd6: ifmap_reg[199:192]  <= i_bram_rdata[7:0];
                    default: ;
                endcase
            end
        end
    end

    // -- CNN Kernel Instantiation --
    cnn_kernel #(
        .KW     (KW),
        .KH     (KH),
        .IF_BW  (IF_BW),
        .W_BW   (W_BW)
    ) u_cnn_kernel (
        .clk        (clk),
        .rst        (rst),
        .i_valid    (kernel_start_valid), // Triggered when data mover is DONE
        .i_fmap     (ifmap_reg),          // Use the internally assembled data
        .i_weight   (i_kernel_weight),    // Pass through from top-level input
        .o_result   (o_final_result),     // Connect to top-level output
        .o_valid    (o_final_valid)       // Connect to top-level output
    );

endmodule
