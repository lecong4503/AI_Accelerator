`timescale 1ns / 1ps

module tb_cnn_kernel;

    parameter KW = 3;
    parameter KH = 3;
    parameter IF_BW = 8;
    parameter W_BW = 8;
    parameter M_BW = 16;
    parameter AC_BW = 20;
    parameter BA_BW = 21;

    reg clk;
    reg rst;
    reg i_valid;
    reg [KW*KH*IF_BW-1:0] i_fmap;
    reg [KW*KH*W_BW-1:0] i_weight;
    wire [AC_BW-1:0] o_result;
    wire o_valid;

    cnn_kernel u_conv (
        .clk(clk),
        .rst(rst),
        .i_valid(i_valid),
        .i_fmap(i_fmap),
        .i_weight(i_weight),
        .o_result(o_result),
        .o_valid(o_valid)
    );

    always
    #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 0;
        i_valid = 0;
        i_fmap = 0;
        i_weight = 0;
    #10
        rst = 1;
    #50
        rst = 0;
    #50
        i_fmap = 72'b0000_1001_0000_1000_0000_0111_0000_0110_0000_0101_0000_0100_0000_0011_0000_0010_0000_0001;
        i_weight = 72'b0000_0001_0000_0010_0000_0011_0000_0100_0000_0101_0000_0110_0000_0111_0000_1000_0000_1001;
        i_valid = 1;
    #100
        i_valid = 0;
    #50
        $finish;
    end
endmodule
