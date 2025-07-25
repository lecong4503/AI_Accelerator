`timescale 1ns / 1ps

module fifo #(
    parameter DEPTH = 4,
    parameter WIDTH = 32,
    parameter LOG2_DEPTH = $clog2(DEPTH)
)
(
    input               clk,
    input               rst,

    input               s_valid,
    output              s_ready,
    input [WIDTH-1:0]   s_data,

    output              m_valid,
    input               m_ready,
    output [WIDTH-1:0]  m_data
);

    wire o_empty,
    wire o_full,

    wire i_hs = s_valid & s_ready;
    wire o_hs = m_valid & m_ready;

    reg [LOG2_DEPTH-1:0] wptr, wptr_nxt;
    reg                  wptr_round, wptr_round_nxt;
    reg [LOG2_DEPTH-1:0] rptr, rptr_nxt;
    reg                  rptr_round, rptr_round_nxt;
    reg [WIDTH-1:0]      cmd_fifo[DEPTH-1:0];

    integer i;
    always @ (posedge clk) begin
        if (rst) begin
            wptr <= 0;
            wptr_round <= 0;
            for (i=0; i<DEPTH; i=i+1)
                cmd_fifo[i] <= {(DEPTH){1'd0}};
        end else if (i_hs) begin
            cmd_fifo[wptr] <= s_data;
            {wptr_round,wptr} <= {wptr_round_nxt,wptr_nxt};
        end
    end

    always @ (*) begin
        if (wptr == (FIFO_DEPTH-1)) begin
            wptr_nxt = 0;
            wptr_round_nxt = ~wptr_round;
        end else begin
            wptr_nxt = wptr + 1;
            wptr_round_nxt = wptr_round;
        end
    end

    always @ (posedge clk) begin
        if (rst) begin
            rptr <= 0;
            rptr_round <= 0;
        end else if (o_hs) begin
            {rptr_round,rptr} <= {rptr_round_nxt,rptr_nxt};
        end
    end

    assign m_data = cmd_fifo[rptr];

    always @ (*) begin
        if (rptr == (FIFO_DEPTH-1)) begin
            rptr_nxt = 0;
            rptr_round_nxt = ~rptr_round;
        end else begin
            rptr_nxt = rptr + 1;
            rptr_round_nxt = rptr_round;
        end
    end

    assign o_empty = (wptr_round == rptr_round) && (wptr == rptr);
    assign o_full = (wptr_round !== rptr_round) && (wptr == rptr);

    assign s_ready = ~o_full;
    assign m_valid = ~o_empty;
    
endmodule