`timescale 1ns / 1ps

module data_mover #(
    parameter KH = 3,
    parameter KW = 3,
    parameter IF_BW = 8,
    parameter W_BW = 8,
    parameter B_BW = 8,
    parameter AC_BW = 20,
    parameter BA_BW = 21,
    // BRAM
    parameter DWIDTH = 32,
    parameter AWIDTH = 3,
    parameter MEM_SIZE = 96
)
(
    input                   clk,
    input                   rst,
    input                   i_run,
    // read fsm state
    //output                  o_r_idle,
    //output                  o_r_read,
    //output                  o_r_send,
    //output                  o_r_done,
    // write fsm state
    //output                  o_w_idle,
    //output                  o_w_write,
    //output                  o_w_done,
    
    // Memory I/F Read - BRAM 0 (IFMAP)
    output  [AWIDTH-1:0]    addr_b0,
    output                  en_b0,
    input   [DWIDTH-1:0]    q_b0,

    // Memory I/F Read - BRAM 1 (WEIGHT)
    output  [AWIDTH-1:0]    addr_b1,
    output                  en_b1,
    input   [DWIDTH-1:0]    q_b1,

    // Memory I/F Write - BRAM 2
    output  [AWIDTH-1:0]    addr_b2,
    output                  en_b2,
    output                  we_b2,
    output  [AC_BW-1:0]     d_b2
);

    localparam R_IDLE = 2'b00;
    localparam R_READ = 2'b01;
    localparam R_SEND = 2'b10;
    localparam R_DONE = 2'b11;

    localparam W_IDLE = 2'b00;
    localparam W_WRITE = 2'b01;
    localparam W_DONE = 2'b10;

    // state update
    reg [1:0] c_r_state, n_r_state;
    reg [1:0] c_w_state, n_w_state;

    always @ (posedge clk) begin
        if (rst) begin
            c_r_state <= R_IDLE;
        end else begin
            c_r_state <= n_r_state;
        end
    end

    always @ (posedge clk) begin
        if (rst) begin
            c_w_state <= W_IDLE;
        end else begin
            c_w_state <= n_w_state;
        end
    end
    
////// READ //////
    // READ FSM
    reg read_done;
    reg send_done;
    
    always @ (*) begin
        n_r_state = c_r_state;
        case (c_r_state) 
        R_IDLE : if (i_run)
                    n_r_state = R_READ;
        R_READ : if (read_done)
                    n_r_state = R_SEND;
        R_SEND : if (send_done)
                    n_r_state = R_DONE;
        R_DONE : n_r_state = R_IDLE;
        endcase
    end

    // READ Signal (addr, en) GEN & Count
    reg [AWIDTH-1:0]        addr_cnt_b0, addr_cnt_b1;
    reg [1:0]               data_cnt_b0, data_cnt_b1;
    reg [KW*KH*IF_BW-1:0]   reg_q_b0;
    reg [KW*KH*W_BW-1:0]    reg_q_b1;
    wire read_en_b0 = (c_r_state == R_READ) && (data_cnt_b0 < 4);

    always @ (posedge clk) begin
        if (rst) begin
            addr_cnt_b0 <= 0;
            data_cnt_b0 <= 0;
        end else if (c_r_state == R_READ) begin
            if (data_cnt_b0 == 3) begin
                data_cnt_b0 <= 0;
            end else begin
                data_cnt_b0 <= data_cnt_b0 + 1;
                addr_cnt_b0 <= addr_cnt_b0 + 1;
            end
        end
    end

    always @ (posedge clk) begin
        if (rst) begin
            addr_cnt_b1 <= 0;
            data_cnt_b1 <= 0;
        end else if (c_r_state == R_READ) begin
            if (data_cnt_b1 == 3) begin
                data_cnt_b1 <= 0;
            end else begin
                data_cnt_b1 <= data_cnt_b1 + 1;
                addr_cnt_b1 <= addr_cnt_b1 + 1;
            end
        end
    end

    always @ (posedge clk) begin
        if (rst) begin
            reg_q_b0 <= 0;
        end else if (read_en_b0) begin
            case (data_cnt_b0)
                2'd0: begin
                    reg_q_b0[7:0]    <= q_b0[7:0];
                    reg_q_b0[15:8]   <= q_b0[15:8];
                    reg_q_b0[23:16]  <= q_b0[23:16];
                    reg_q_b0[31:24]  <= q_b0[31:24];
                end
                2'd1: begin
                    reg_q_b0[39:32]  <= q_b0[7:0];
                    reg_q_b0[47:40]  <= q_b0[15:8];
                    reg_q_b0[55:48]  <= q_b0[23:16];
                    reg_q_b0[63:56]  <= q_b0[31:24];
                end
                2'd2: begin
                    reg_q_b0[71:64]  <= q_b0[7:0];
                    // 나머지 2개는 padding or don't care
                end
            endcase
        end
    end

    always @ (posedge clk) begin
        if (rst) begin
            reg_q_b1 <= 0;
        end else if (read_en_b1) begin
            case (data_cnt_b1)
                2'd0: begin
                    reg_q_b1[7:0]    <= q_b1[7:0];
                    reg_q_b1[15:8]   <= q_b1[15:8];
                    reg_q_b1[23:16]  <= q_b1[23:16];
                    reg_q_b1[31:24]  <= q_b1[31:24];
                end
                2'd1: begin
                    reg_q_b1[39:32]  <= q_b1[7:0];
                    reg_q_b1[47:40]  <= q_b1[15:8];
                    reg_q_b1[55:48]  <= q_b1[23:16];
                    reg_q_b1[63:56]  <= q_b1[31:24];
                end
                2'd2: begin
                    reg_q_b1[71:64]  <= q_b1[7:0];
                    // 나머지 2개는 padding or don't care
                end
            endcase
        end
    end

    assign addr_b0 = addr_cnt_b0;
    assign addr_b1 = addr_cnt_b1;

    always @ (posedge clk) begin
        if (rst) begin
            read_done <= 0;
        end else if (data_cnt_b0 == 3 && data_cnt_b1 == 3) begin
            read_done <= 1;
        end else begin
            read_done <= 0;
        end
    end

    assign en_b0 = (c_r_state == R_READ);
    assign en_b1 = (c_r_state == R_READ);

    // SEND
    reg [KW*KH*IF_BW-1:0]   r_ifmap;
    reg [KW*KH*W_BW-1:0]    r_weight;
    reg                     r_i_valid;

    always @ (posedge clk) begin
        if (rst) begin
            r_ifmap <= 0;
            r_weight <= 0;
            r_i_valid <= 0;
        end else if (c_r_state == R_SEND) begin
            r_ifmap <= reg_q_b0;
            r_weight <= reg_q_b1;
            r_i_valid <= 1;
        end else begin
            r_i_valid <= 0;
        end
    end

    always @ (posedge clk) begin
        if (rst) begin
            send_done <= 0;
        end else if (c_r_state == R_SEND) begin
            send_done <= 1;
        end else begin
            send_done <= 0;
        end
    end

////// WRITE ///////
    // WRITE FSM
    wire write_done;
    
    always @ (*) begin
        n_w_state = c_w_state;
        case (c_w_state)
        W_IDLE : if (i_run)
                    n_w_state = W_WRITE;
        W_WRITE : if (write_done)
                    n_w_state = W_DONE;
        W_DONE : n_w_state = W_IDLE;
        default : n_w_state = W_IDLE;
        endcase
    end

    // WRITE State
    wire [AC_BW-1:0] w_result;
    wire             w_o_valid;

    reg  [AC_BW-1:0] r_result;
    reg  [AWIDTH-1:0] addr_cnt_b2;

    always @ (posedge clk) begin
        if (rst) begin
            r_result <= 0;
        end else if (w_o_valid == 1) begin
            r_result <= w_result;
        end
    end

    always @ (posedge clk) begin
        if (rst) begin
            addr_cnt_b2 <= 0;
        end else if ((c_w_state == W_WRITE) && w_o_valid) begin
            addr_cnt_b2 <= addr_cnt_b2 + 1;
        end
    end

    assign addr_b2 = addr_cnt_b2;
    assign en_b2 = (c_w_state == W_WRITE) && w_o_valid;
    assign we_b2 = (c_w_state == W_WRITE) && w_o_valid;
    assign d_b2 = r_result;
    assign write_done = en_b2 && we_b2;

////// CNN KERNEL //////

        cnn_kernel u_kernel (
        .clk(clk),
        .rst(rst),
        .i_valid(r_i_valid),
        .i_fmap(r_ifmap),
        .i_weight(r_weight),
        .o_result(w_result),
        .o_valid(w_o_valid)
    );

endmodule