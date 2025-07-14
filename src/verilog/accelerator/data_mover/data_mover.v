`timescale 1ns / 1ps

module data_mover #(
    parameter KW        = 5,
    parameter KH        = 5,
    parameter IF_BW     = 8,
    parameter W_BW      = 8,
    parameter B_BW      = 8,
    parameter M_BW      = 16,
    parameter AC_BW     = 21,
    parameter AB_BW     = 22,
    // BRAM
    parameter AWIDTH    = 6,
    parameter DWIDTH    = 32,
    // Line Buffer
    parameter PIXEL     = 4,
    parameter TOTAL_PIX = KW * KH,
    parameter QUOTIENT  = TOTAL_PIX / PIXEL,
    parameter HAS_REM   = TOTAL % PIXEL,
    parameter N_CYCLES  = QUOTIENT + HAS_REM
)
(
    input clk,
    input rst,
    input i_run,

    // IFMAP - BRAM 0
    input [DWIDTH-1:0] i_fmap,
    output en,
    output [AWIDTH-1:0] addr,
    output [KH*KW*D_BW-1:0] o_fmap

    // WEIGHT - BRAM 1
    input [DWIDTH-1:0] i_weight
);

    localparam IDLE = 2'b00;
    localparam READ = 2'b01;
    localparam SEND = 2'b10;
    localparam DONE = 2'b11;

    reg [1:0] c_state, n_state;

    always @ (posedge clk) begin
        if (rst) begin
            c_state <= IDLE;
        end else begin
            c_state <= n_state;
        end
    end

    reg read_done;
    reg send_done;

    always @ (*) begin
        n_state <= c_state;
        case (c_state) 
            IDLE : if (i_run)
                n_state <= READ;
            READ : if (read_done)
                n_state <= SEND;
            SEND : if (send_done)
                n_state <= DONE;
            DONE : n_state <= IDLE;
            default : n_state <= IDLE;
        endcase
    end

    reg [AWIDTH-1:0] addr_cnt;
    reg [AWIDTH-1:0] data_idx;

    wire w_en = (c_state == READ) && (addr_cnt < 8);
    
    always @ (posedge clk) begin
        if (rst) begin
            addr_cnt <= 0;
        end else if (c_state == READ) begin
            if (addr_cnt < 8)
                addr_cnt <= addr_cnt + 1;
        end else begin
            addr_cnt <= 0;
        end
    end

    assign addr = addr_cnt;
    assign en = w_en;
    
    always @ (posedge clk) begin
        if (rst) begin
            data_idx <= 0;
        end else if (c_state == READ) begin
            if (addr_cnt < 8)
                data_idx <= addr_cnt;
        end else begin
            data_idx <= 0;
        end
    end

    reg [KW*KH*D_BW-1:0] r_buff_fmap;

    always @ (posedge clk) begin
        if (rst) begin
            r_buff_fmap <= 0;
        end else if (c_state == READ) begin
            case (data_idx)
                6'd1 : r_buff_fmap[31:0] <= i_fmap;
                6'd2 : r_buff_fmap[63:32] <= i_fmap;
                6'd3 : r_buff_fmap[95:64] <= i_fmap;
                6'd4 : r_buff_fmap[127:96] <= i_fmap;
                6'd5 : r_buff_fmap[159:128] <= i_fmap;
                6'd6 : r_buff_fmap[191:160] <= i_fmap;
                6'd7 : r_buff_fmap[199:192] <= i_fmap[7:0];
            default : ;
            endcase
        end
    end

    always @ (posedge clk) begin
        if (rst) begin
            read_done <= 0;
        end else if (data_idx == 7) begin
            read_done <= 1;
        end else begin
            read_done <= 0;
        end
    end

    reg [KW*KH*D_BW-1:0] r_buff_out_fmap;
    
    always @ (posedge clk) begin
        if (rst) begin
            r_buff_out_fmap <= 0;
            send_done <= 0;
        end else if (c_state == SEND) begin
            r_buff_out_fmap <= r_buff_fmap;
            send_done <= 1;
        end else begin
            send_done <= 0;
        end
    end

    assign o_fmap = r_buff_out_fmap;

endmodule
    