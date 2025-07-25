`timescale 1ns / 1ps

module mem_read #(
    parameter DWIDTH = 32,
    parameter DEPTH = 256,
    parameter AWIDTH = $clog2(DEPTH)
)
(
    input               clk,
    input               rst, 
    input               i_run,
    output              o_read_done,

////// Module Interface - Access to other module
    output              m_valid,
    input               m_ready,
    output [DWIDTH-1:0] m_data,

////// BRAM Interface - Access to BRAM
    output [AWIDTH-1:0] addr,
    output              en,
    input  [DWIDTH-1:0] din
);

    wire read_en = (i_run) && (!read_done) && m_ready && (addr_cnt<DEPTH);

    reg [AWIDTH-1:0]    addr_cnt;
    reg                 read_done;

    // addr cnt
    always @ (posedge clk) begin
        if (rst) begin
            addr_cnt <= 0;
        end else if (read_en) begin
            if (addr_cnt < DEPTH-1) begin
                addr_cnt <= addr_cnt + 1;
            end
        end else if (!i_run) begin
            addr_cnt <= 0;
        end
    end

    always @ (posedge clk) begin
        if (rst || !i_run) begin
            read_done <= 0;
        end else if (read_fmap_valid && addr_cnt == DEPTH-1) begin
            read_done <= 1;
        end
    end

    assign en = read_en;
    assign o_read_done = read_done;
    assign addr = addr_cnt;

    // 1 delay for valid signal gen
    reg read_fmap_valid;

    always @ (posedge clk) begin
        if (rst) begin
            read_fmap_valid <= 0;
        end else begin
            read_fmap_valid <= read_en;
        end
    end    

    assign m_valid = read_fmap_valid;

    // Data store
    reg [DWIDTH-1:0] r_fmap_packet;

    always @ (posedge clk) begin
        if (rst) begin
            r_fmap_packet <= 0;
        end else if (read_fmap_valid) begin
            r_fmap_packet <= din;
        end
    end

    assign m_data = r_fmap_packet;

endmodule