`timescale 1ns / 1ps

module cnn_kernel #(
    parameter KW = 3,
    parameter KH = 3,
    parameter IF_BW = 8,
    parameter W_BW  = 8,
    parameter B_BW  = 8,
    parameter M_BW  = 16,
    parameter AC_BW = 20,
    parameter BA_BW = 21
)(
    input                       clk,
    input                       rst,
    input                       i_valid,

    input  [KW*KH*IF_BW-1:0]    i_fmap,
    input  [KW*KH*W_BW-1:0]     i_weight,

    output [AC_BW-1:0]          o_result,
    output                      o_valid
);

    localparam DELAY = 2;
    wire [DELAY-1:0] ce;
    reg  [DELAY-1:0] r_valid;

    always @(posedge clk) begin
        if (rst)
            r_valid <= 0;
        else begin
            r_valid[0] <= i_valid;
            r_valid[1] <= r_valid[0];
        end
    end

    assign ce = r_valid;

    // mul
    reg  [KW*KH*M_BW-1:0] r_mul;
    wire [KW*KH*M_BW-1:0] w_mul;

    genvar m;
    generate
        for (m = 0; m < KH*KW; m = m + 1) begin : gen_MUL
            assign w_mul[m*M_BW +: M_BW] = i_fmap[m*IF_BW +: IF_BW] * i_weight[m*W_BW +: W_BW];

            always @(posedge clk) begin
                if (rst)
                    r_mul[m*M_BW +: M_BW] <= 0;
                else if (i_valid)
                    r_mul[m*M_BW +: M_BW] <= w_mul[m*M_BW +: M_BW];
            end
        end
    endgenerate

    // sum
    reg [AC_BW-1:0] r_o_result;
    integer i;
    always @(*) begin
        r_o_result = 0;
        for (i = 0; i < KH*KW; i = i + 1)
            r_o_result = r_o_result + r_mul[i*M_BW +: M_BW];
    end

    reg [AC_BW-1:0] r_delay_o_result;
    always @(posedge clk) begin
        if (rst)
            r_delay_o_result <= 0;
        else if (ce[DELAY-2])
            r_delay_o_result <= r_o_result;
    end

    assign o_valid = r_valid[DELAY-1];
    assign o_result = r_delay_o_result;

endmodule
