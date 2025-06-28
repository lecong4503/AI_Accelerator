`timescale 1ns / 1ps

module cnn_kernel #(
    // Kernel Size
    parameter KW = 3,
    parameter KH = 3,

    // Input Feature Map & Weight & Bias Bit Width
    parameter IF_BW = 8,    // Input Feature Map Bit Width
    parameter W_BW = 8,     // Weight Bit Width
    parameter B_BW = 8,     // Bias Bit Width

    parameter M_BW = 16,    // Multuplication Bit Width
    parameter AC_BW = 20,   // Accumulate Bit Width
    parameter BA_BW = 21,   // Bias Addition Bit Width
)
(
    input                       clk             ,
    input                       rst             ,
    input                       i_valid         ,

    input [KW*KH*IF_BW-1:0]     i_fmap          ,
    input [KW*KH*W_BW-1:0]      i_weight        ,

    output [BA_BW-1:0]          o_result        ,
    output                      o_valid
);

    //=======================================================================================
    // Data Enable Signals & Delay --> 2Cycle

        localparam DELAY = 2;

        wire [DELAY-1:0]    ce;
        reg  [DELAY-1:0]    r_valid;

        always @ (posedge clk) begin
            if (rst) begin
                r_valid <= {DELAY{1'b0}};
            end else begin
                r_valid[DELAY-2] <= i_valid;
                r_valid[DELAY-1] <= r_valid[DELAY-2];
            end
        end

        assign ce = r_valid;  

    //=======================================================================================
    // mul

    reg  [KW*KH*M_BW-1:0] r_mul;
    wire [KW*KH*M_BW-1:0] w_mul;

    genvar m, n;
    generate
        for (m=0; m<KH; m=m+1) begin
            for (n=0; n<KW; n=n+1) begin
                
                assign w_mul[KH*KW*M_BW +: M_BW] = i_fmap[KW*KH*IF_BW +: IF_BW] * i_weight[KW*KH*W_BW +: W_BW];

                always @ (posedge clk) begin
                    if (rst) begin
                        r_mul[KH*KW*M_BW +: M_BW] <= {M_BW{1'b0}};
                    end else if(i_in_valid) begin
                        r_mul[KH*KW*M_BW +: M_BW] <= w_mul[KH*KW*M_BW +: M_BW];
                    end
                end
            end
        end
    endgenerate

    //=======================================================================================
    // sum

    reg [AC_BW-1:0] r_o_result;
    reg [AC_BW-1:0] r_delay_o_result;

    genvar i, j;
    generate
        always @ (*) begin
            r_o_result[0 +: AC_BW] = {AC_BW{1'b0}};

            for (i=0; i<OH; i=i+1) begin
                for (j=0; j<OW; j=j+1) begin
                    r_o_result [0 +: AC_BW] = r_o_result[0 +: AC_BW] + r_mul[KH*KW*M_BW +: M_BW];
                end
            end

            always @ (posedge clk) begin
                if (rst) begin
                    r_delay_o_result <= {AC_BW{1'b0}};
                end else if (ce[DELAY-2]) begin
                    r_delay_o_result <= r_o_result;
                end
            end
        end
    endgenerate

    assign o_valid = r_valid[DELAY-1];
    assign o_result = r_delay_o_result;

endmodule








