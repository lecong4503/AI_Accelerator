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
    parameter AWIDTH    = 8,
    parameter DWIDTH    = 32,
    // Line Buffer
    parameter PACKET     = 4,
    parameter TOTAL_PIX = KW * KH,
    parameter QUOTIENT  = TOTAL_PIX / PACKET,
    parameter HAS_REM   = TOTAL_PIX % PACKET,
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
    localparam RUN  = 2'b01;
    localparam DONE = 2'b10;

    //// State Update
    reg [1:0] c_state, n_state;

    always @ (posedge clk) begin
        if (rst) begin
            c_state <= IDLE;
        end else begin
            c_state <= n_state;
        end
    end

    //// FSM Update
    reg run_done;
    reg send_done;

    always @ (*) begin
        n_state <= c_state;
        case (c_state) 
            IDLE : if (i_run)
                n_state <= RUN;
            RUN  : if (run_done)
                n_state <= DONE;
            DONE : n_state <= IDLE;
            default : n_state <= IDLE;
        endcase
    end

////// 1. Receive to Bram Data //////
    reg [DWIDTH-1:0] r_fmap_packet;
    reg [AWIDTH-1:0] addr_cnt;
    reg fmap_valid, fmap_pix_ready;
    reg read_en_d1;

    wire read_en = fmap_pix_ready && addr_cnt < 256 && c_state == RUN;
    wire w_en = read_en;
    
    // address counter
    always @ (posedge clk) begin
        if (rst) begin
            addr_cnt <= 0;
        end else if (read_en) begin
            if (addr_cnt < 256)
                addr_cnt <= addr_cnt + 1;
        end
    end

    assign addr = addr_cnt;
    assign en = w_en;

    // 1 clk delay - ifmap valid
    always @ (posedge clk) begin
        if (rst) begin
            read_en_d1 <= 0;
        end else begin
            read_en_d1 <= read_en;
        end
    end

    always @ (posedge clk) begin
        if (rst) begin
            fmap_valid <= 0;
        end else begin
            fmap_valid <= read_en_d1;
        end
    end

    // FMAP(PACKET) REG
    always @ (posedge clk) begin
        if (rst) begin
            r_fmap_packet <= 0;
        end else if (fmap_valid) begin
            r_fmap_packet <= i_fmap;
        end
    end

////// 2. Devide Packet -> 4 Pixels //////
    reg [IF_BW-1:0] r_fmap_pix [0:PACKET-1];
    reg [1:0] fmap_pix_cnt;
    reg fmap_pix_valid;
    reg busy;

    wire fmap_pix_ready;
    wire hs_fmap_packet_in = fmap_valid && fmap_pix_ready; 

    assign fmap_pix_ready = ~busy;

    always @ (posedge clk) begin
        if (rst) begin
            fmap_pix_valid <= 0;
        end else begin
            fmap_pix_valid <= hs_fmap_packet_in;
        end
    end

    always @ (posedge clk) begin
        if (rst) begin
            busy <= 0;
            fmap_pix_cnt <= 0;
        end else if (hs_fmap_packet_in) begin
            if (fmap_pix_cnt == 3) begin
                fmap_pix_cnt <= 0;
                busy <= 0;
            end else begin
                fmap_pix_cnt <= fmap_pix_cnt + 1;
                busy <= 1;
            end
        end
    end

    genvar i;
    generate
        for (i=0; i<PACKET; i=i+1) begin : PIXEL_DEVIDE
            always @ (posedge clk) begin
                if (rst) begin
                    r_fmap_pix[i] <= {IF_BW{1'b0}};
                end else if (fmap_pix_valid) begin
                    r_fmap_pix[i] <= r_fmap_packet[i*IF_BW +: IF_BW];
                end
            end
        end
    endgenerate

////// 3. Shift Fmap
    reg [IF_BW-1:0] shift_fmap[27:0];

    always @ (posedge clk) begin
        if (rst) begin
            fmap_pix_idx <= 0;
        end else if (fmap_pix_valid) begin
            if (fmap_pix_idx < 4) begin
                r_fmap_pix_idx <= r_fmap_pix_idx + 1;
            end else begin
                r_fmap_pix_idx <= 0;
            end
        end
    end


endmodule
    