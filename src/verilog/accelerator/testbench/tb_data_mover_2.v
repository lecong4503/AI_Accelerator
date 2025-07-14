`timescale 1ns / 1ps

module tb_data_mover;

    // ============================
    // Parameters for 5x5 kernel
    // ============================
    parameter KW = 5;
    parameter KH = 5;
    parameter D_BW = 8;
    parameter AWIDTH = 6;
    parameter DWIDTH = 32;

    // ============================
    // Signal Declarations
    // ============================
    reg clk, rst;
    reg i_run;

    wire [KH*KW*D_BW-1:0] o_data;

    // ============================
    // DUT: Top Module
    // ============================
    top_data_mover uut (
        .clk            (clk),
        .rst            (rst),
        .i_run          (i_run),
        .o_data         (o_data)
    );

    // ============================
    // Clock Generation
    // ============================
    always #5 clk = ~clk;

    // ============================
    // Stimulus
    // ============================
    initial begin
        clk = 0;
        rst = 0;
        i_run = 0;

        #10  rst = 1;
        #50  rst = 0;
        #50  i_run = 1;
        #10  i_run = 0;  // Pulse trigger
        #200;

        $finish;
    end

endmodule
