`timescale 1ns / 1ps

module data_send #(
    parameter KW = 5,
    parameter KH = 5,

    parameter IF_BW = 8,
    parameter W_BW = 8,
    parameter B_BW = 8,

    parameter DWIDTH = 32,
    parameter PIXEL = 4,

    parameter SR_LEN = 28 
)
(
    input clk,
    input rst,
    input i_run,

    input  [DWIDTH-1:0] s_data,
    output              s_ready,
    input               s_valid,

    output [IF_BW-1:0]  m_fmap,
    input               m_ready,
    output              m_valid
);

    reg [IF_BW-1:0] r_fmap_pix [0:PIXEL-1];
    reg [1:0]       fmap_pix_ptr;
    reg busy;

    wire ready = ~busy;
    wire i_hs = s_valid && ready;

    assign s_ready = ready;

    integer i;
    always @ (posedge clk) begin
        for (i=0; i<PIXEL; i=i+1) begin
            if (rst) begin
                r_fmap_pix[i] <= {IF_BW{1'b0}};
            end else if (i_hs) begin
                r_fmap_pix[i] <= s_data[i*IF_BW +: IF_BW];
            end

        assign w_fmap_pix <= r_fmap_pix[i];

        end
    end

    always @ (posedge clk) begin
        if (rst) begin
            fmap_pix_ptr <= 0;
        end else if (i_hs) begin
            if (fmap_pix_ptr == 3) begin
                fmap_pix_ptr <= 0;
            end else begin
                fmap_pix_ptr <= fmap_pix_ptr + 1;
            end
        end
    end

    always @ (posedge clk) begin
        if (rst) begin
            busy <= 0;
        end else if (i_hs) begin
            busy <= 1;
        end else if (busy && m_ready && fmap_pix_idx == 3) begin
            busy <= 0;
        end
    end

    assign s_ready = !busy;
    
    // shift reg
    reg [IF_BW-1:0] fmap_shift_reg [0:27];

    integer j;
    always @ (posedge clk) begin
        if (rst) begin
            for (j=0; j<28; j=j+1) begin
                fmap_shift_reg[j] <= {IF_BW{1'b0}};
            end
        end else if (fmap_pix_valid) begin
            if (j == 0)
                fmap_shift_reg[0] <= w_fmap_pix;
            else
                fmap_shift_reg[j] <= fmap_shift_reg[j-1];
        end
    end
