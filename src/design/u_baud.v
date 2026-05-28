`include "inc.vh"

module u_baud (
    input sys_clk,
    input sys_rst_l,
    output reg uart_clk
);

reg [`CW-1:0] cnt;

always @(posedge sys_clk or negedge sys_rst_l) begin
    if(!sys_rst_l) begin
        cnt <= 0;
        uart_clk <= 0;
    end 
    else begin
        if(cnt == `CLK_DIV - 1) begin
            uart_clk <= ~uart_clk;
            cnt <= 0;
        end
        else begin
            cnt <= cnt + 1;
        end
    end
end
    
endmodule