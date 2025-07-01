`timescale 1ns / 1ps

module tb_cnn_kernel;

    reg clk;
    reg rst;
    reg i_valid;
    reg [KW*KH*IF_BW-1:0] i_fmap;
    reg [KW*KH*W_BW-1:0] i_weight;

    