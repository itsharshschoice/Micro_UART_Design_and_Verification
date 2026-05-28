`include "inc.vh"

module u_xmit (
    input uart_clk,
    input sys_rst_l,
    input xmitH,
    input [`WORD_LEN-1:0] xmit_dataH,
    output reg uart_XMIT_dataH,
    output reg xmit_doneH,
    output reg xmit_active   
);

reg [3:0] cnt1;  // to count 16 cycles 
reg [$clog2(`WORD_LEN):0] cnt2; // to transmit data bits
reg [`WORD_LEN-1:0] xmit_data_temp;
reg xmitH_prev;

localparam S0 = 2'b00,
           S1 = 2'b01,
           S2 = 2'b10,
           S3 = 2'b11;
reg [1:0] PS, NS;

always @(posedge uart_clk or negedge sys_rst_l) begin
    if(!sys_rst_l)
        xmitH_prev <= 0;
    else
        xmitH_prev <= xmitH;
end 

always @(posedge uart_clk or negedge sys_rst_l) begin
    if(!sys_rst_l) begin
        cnt1 <= 0;
        cnt2 <= 0;
        xmit_data_temp <= 0;
        uart_XMIT_dataH <= 1; // Idle state of TX line is high
        xmit_doneH <= 1;
        xmit_active <= 0;
        PS <= S0;
    end
    else begin
        PS <= NS;
        case (PS)
            S0: begin  // idle state
                if(xmitH > xmitH_prev) begin  // rising edge of xmitH pulse
                    xmit_active <= 1;
                    xmit_doneH <= 0;
                    xmit_data_temp <= xmit_dataH;
                    NS <= S1;  
                end
                else begin
                    NS <= S0;
                end
            end
            S1: begin // transmit start bit (0)
                uart_XMIT_dataH <= 0;
                if (cnt1 == 4'd15) begin
                    NS <= S2;
                    cnt1 <= 0;
                end
                else begin
                    NS <= S1;
                    cnt1 <= cnt1 + 1;
                end
            end
            S2: begin // transmit data bits (d0 to d7) 
                if(cnt2 == `WORD_LEN) begin
                    NS <= S3;
                    cnt2 <= 0;
                    cnt1 <= 0;
                end
                else begin
                    uart_XMIT_dataH <= xmit_data_temp[cnt2];
                    if(cnt1 == 15) begin
                        NS <= S2;
                        cnt1 <= 0;
                        cnt2 <= cnt2 + 1;
                    end
                    else begin
                        NS <= S2;
                        cnt1 <= cnt1 + 1;
                    end   
                end
            end
            S3: begin // transmit stop bit (1) and update outputs
                uart_XMIT_dataH <= 1;
                if(cnt1 == 15) begin
                    NS <= S0;
                    cnt1 <= 0;
                    xmit_doneH <= 1;
                    xmit_active <= 0;
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