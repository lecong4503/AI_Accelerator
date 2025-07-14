`timescale 1ns / 1ps

module tb_data_mover;

    // ============================
    // Parameters for 5x5 kernel
    // ============================
    parameter KH = 5;
    parameter KW = 5;
    parameter IF_BW = 8;
    parameter W_BW = 8;
    parameter M_BW = 16;
    parameter AC_BW = M_BW + $clog2(KW*KH);
    parameter BA_BW = 21;
    parameter DWIDTH = 32;
    parameter MEM_SIZE = 96;

    // ============================
    // Signal Declarations
    // ============================
    reg clk, rst;
    reg i_run;

    wire [AC_BW-1:0] o_final_result;  // 200-bit
    wire                   o_final_valid;

    // ============================
    // DUT: Top Module
    // ============================
    top_data_mover #(
        .KH(KH),
        .KW(KW),
        .IF_BW(IF_BW),
        .W_BW(W_BW),
        .AC_BW(AC_BW),
        .BA_BW(BA_BW),
        .DWIDTH(DWIDTH),
        .MEM_SIZE(MEM_SIZE)
    ) uut (
        .clk            (clk),
        .rst            (rst),
        .i_run          (i_run),
        .o_final_result (o_final_result),
        .o_final_valid  (o_final_valid)
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
