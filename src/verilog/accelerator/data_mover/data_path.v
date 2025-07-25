`timescale 1ns / 1ps

module data_path #(
    parameter KW = 3,
    parameter KH = 3,

    parameter IF_BW = 8,
    parameter W_BW = 8,
    parameter B_BW = 8,

    parameter DWIDTH = 32,
    parameter PIXEL = 4,

    parameter SR_LEN = KH*KW
)
(
    input                       clk,
    input                       rst,
    input                       i_run,

    input  [DWIDTH-1:0]         s_data,
    output                      s_ready,
    input                       s_valid,

    output [IF_BW*KH*KW-1:0]    m_fmap,
    input                       m_ready,
    output                      m_valid
);

    reg [IF_BW-1:0] r_fmap_pix [0:PIXEL-1];

    integer i;
    always @ (posedge clk) begin
        for (i=0; i<PIXEL; i=i+1) begin
            r_fmap_pix[i] <= {IF_BW{1'b0}};
        end else begin
            r_fmap_pix[i] <= s_data[i*IF_BW +: IF_BW];
        end
    end

    wire [IF_BW-1:0] w_fmap_pix;

    assign w_fmap_pix = r_fmap_pix;

    reg [IF_BW-1:0] shift_fmap [0:(KW*KH)-1];

    genvar k;
    generate 
        for (k=0; k<KW*KH; k=k+1) begin : SR_FMAP
            always @ (posedge clk) begin
                if (rst)begin
                    shift_fmap[k] <= {IF_BW{1'b0}};
                end else begin
                    if (k == 0)
                        shift_fmap[0] <= w_fmap_pix;
                    else if (k > 0)
                        shift_fmap[k] <= shift_fmap[k-1];
                end
            end
        end
    endgenerate
        
    assign m_fmap = {shift_fmap[27], shift_fmap[26],
                     shift_fmap[25], shift_fmap[24],
                     shift_fmap[23], shift_fmap[22],
                     shift_fmap[21], shift_fmap[20],
                     shift_fmap[19], shift_fmap[18],
                     shift_fmap[17], shift_fmap[16],
                     shift_fmap[15], shift_fmap[14],
                     shift_fmap[13], shift_fmap[12],
                     shift_fmap[11], shift_fmap[10],
                     shift_fmap[9], shift_fmap[8],
                     shift_fmap[7], shift_fmap[6],
                     shift_fmap[5], shift_fmap[4],
                     shift_fmap[3], shift_fmap[2],
                     shift_fmap[1], shift_fmap[0],
                    };

endmodule 