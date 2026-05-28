`include "inc.vh"

module u_rec (
    input uart_clk,
    input sys_rst_l,
    input uart_REC_dataH,
    output reg [`WORD_LEN-1:0] rec_dataH,
    output reg rec_readyH,
    output reg rec_busy  
);

reg [3:0] cnt1;  // to count 8 and 16 cycles
reg [$clog2(`WORD_LEN):0] cnt2; // to receive data bits
reg [`WORD_LEN-1:0] rec_data_temp;
reg uart_REC_dataH_prev;

reg start_bit_error;
reg stop_bit_error;

localparam S0 = 2'b00,
           S1 = 2'b01,
           S2 = 2'b10,
           S3 = 2'b11;
reg [1:0] PS, NS;

always @(posedge uart_clk or negedge sys_rst_l) begin
    if(!sys_rst_l)
        uart_REC_dataH_prev <= 1;
    else
        uart_REC_dataH_prev <= uart_REC_dataH;
end 

always @(posedge uart_clk or negedge sys_rst_l) begin
    if(!sys_rst_l) begin
        cnt1 <= 0;
        cnt2 <= 0;
        rec_data_temp <= 0;
        start_bit_error <= 0;
        stop_bit_error <= 0;
        rec_readyH <= 1;
        rec_busy <= 0;
        PS <= S0;
    end
    else begin
        PS <= NS;
        case(PS)
            S0: begin // idle state
                if(uart_REC_dataH < uart_REC_dataH_prev) begin
                    rec_readyH <= 0;
                    rec_busy <= 1;
                    NS <= S1;
                    cnt1 <= 1; // counting already started with the first falling edge
                end
                else
                    NS <= S0;
            end
            S1: begin // receive start bit (0)
                if(cnt1 == 4'd15 && start_bit_error) begin
                    rec_readyH <= 1;
                    rec_busy <= 0;
                    start_bit_error <= 0;
                    NS <= S0;
                    cnt1 <= 0;
                end
                else if (cnt1 == 4'd15 && !start_bit_error) begin
                    NS <= S2;
                    cnt1 <= 0;
                end
                else if (cnt1 == 4'd7 && uart_REC_dataH != 1'b0) begin
                    start_bit_error <= 1;
                    NS <= S1;
                    cnt1 <= cnt1 + 1;
                end
                else begin
                    NS <= S1;
                    cnt1 <= cnt1 + 1;
                end
            end
            S2: begin  // receive data bits
                if(cnt2 == `WORD_LEN) begin
                    NS <= S3;
                    cnt1 <= 0;
                    cnt2 <= 0;
                end
                else begin
                    if (cnt1 == 4'd15) begin
                        NS <= S2;
                        cnt2 <= cnt2 + 1;
                        cnt1 <= 0;
                    end
                    else if (cnt1 == 4'd7) begin
                        rec_data_temp[cnt2] <= uart_REC_dataH;
                        NS <= S2;
                        cnt1 <= cnt1 + 1;
                    end
                    else begin
                        NS <= S2;
                        cnt1 <= cnt1 + 1;
                    end
                end
            end
            S3: begin // receive stop bit (1) and update outputs
                if(cnt1 == 4'd15 && stop_bit_error) begin
                    rec_readyH <= 1;
                    rec_busy <= 0;
                    stop_bit_error <= 0;
                    NS <= S0;
                    cnt1 <= 0;
                end
                else if (cnt1 == 4'd15 && !stop_bit_error) begin
                    rec_readyH <= 1;
                    rec_busy <= 0;
                    rec_dataH <= rec_data_temp;
                    NS <= S0;
                    cnt1 <= 0;
                end
                else if (cnt1 == 4'd7 && uart_REC_dataH != 1'b1) begin
                    stop_bit_error <= 1;
                    NS <= S3;
                    cnt1 <= cnt1 + 1;
                end
                else begin
                    NS <= S3;
                    cnt1 <= cnt1 + 1;
                end
            end

            default: NS <= S0;
        endcase
    end       
end
    
endmodule