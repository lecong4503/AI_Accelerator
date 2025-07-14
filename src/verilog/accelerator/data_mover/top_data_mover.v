`timescale 1ns / 1ps

module top_data_mover #(
    parameter KW = 5,
    parameter KH = 5,
    parameter D_BW = 8,
    parameter AWIDTH = 6,
    parameter DWIDTH = 32
)(
    input clk,
    input rst,
    input i_run,

    output [KW*KH*D_BW-1:0] o_data
);

    // Internal wires
    wire [AWIDTH-1:0] bram_addr;
    wire              bram_en;
    wire [KW*KH*D_BW-1:0] bram_rdata;

    // Instantiate Data Mover (includes kernel)
    data_mover uut (
        .clk    (clk),
        .rst    (rst),
        .i_run  (i_run),
        .i_data (bram_rdata),
        .en     (bram_en),
        .addr   (bram_addr),
        .o_data (o_data)
    );

    // Instantiate BRAM
    blk_mem_gen_0 u_bram (
        .clka   (clk),
        .ena    (bram_en),
        .addra  (bram_addr),
        .douta  (bram_rdata)
    );

endmodule
