`timescale 1ns / 1ps

module shift_reg (
    input clk,
    input rst,
    input i_run,
    input [31:0] i_data,
    output [71:0] o_data
);

    localparam IDLE = 2'b00;
    localparam RUN = 2'b01;
    localparam DONE = 2'b10;

    reg [7:0] sr [8:0];
    reg [3:0] idx;
    reg [1:0] c_state, n_state;
    wire en = idx < 9;

    always @ (posedge clk) begin
        if (rst) begin
            c_state <= IDLE;
        end else begin
            c_state <= n_state;
        end
    end

    always @ (*) begin
        n_state = c_state;
        case (c_state)
            IDLE : if (i_run)
                    n_state = RUN;
            RUN : if (done)
                    n_state = DONE;
            DONE : n_state = IDLE;
            default : n_state = IDLE;
        endcase
    end

    always @ (posedge clk) begin
        if (rst) begin
            idx <= 0;
        end else if (c_state == RUN) begin
            if (idx == 9) begin
                idx <= 0;
            end else begin
                idx <= idx + 1;
            end
        end
    end
            
    always @ (posedge clk) begin
        if (rst) begin
            sr[0] <= 0;
            sr[1] <= 0;
            sr[2] <= 0;
            sr[3] <= 0;
            sr[4] <= 0;
            sr[5] <= 0;
            sr[6] <= 0;
            sr[7] <= 0;
            sr[8] <= 0;
        end else if (en) begin
            sr[8] <= sr[7];
            sr[7] <= sr[6];
            sr[6] <= sr[5];
            sr[5] <= sr[4];
            sr[4] <= sr[3];
            sr[3] <= sr[2];
            sr[2] <= sr[1];
            sr[1] <= sr[0];
            sr[0] <= 
    