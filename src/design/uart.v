`include "inc.vh"

module uart (
    input sys_clk,
    input sys_rst_l,
    input xmitH,
    input [`WORD_LEN-1:0] xmit_dataH,
    input uart_REC_dataH,
    output uart_XMIT_dataH,
    output xmit_doneH,
    output xmit_active,
    output [`WORD_LEN-1:0] rec_dataH,
    output rec_readyH,
    output rec_busy 
);

wire uart_clk;

u_baud baud_gen (
    .sys_clk(sys_clk),
    .sys_rst_l(sys_rst_l),
    .uart_clk(uart_clk)
);

u_xmit transmitter (
    .uart_clk(uart_clk),
    .sys_rst_l(sys_rst_l),
    .xmitH(xmitH),
    .xmit_dataH(xmit_dataH),
    .uart_XMIT_dataH(uart_XMIT_dataH),
    .xmit_doneH(xmit_doneH),
    .xmit_active(xmit_active)
);

u_rec receiver (
    .uart_clk(uart_clk),
    .sys_rst_l(sys_rst_l),
    .uart_REC_dataH(uart_REC_dataH),
    .rec_dataH(rec_dataH),
    .rec_readyH(rec_readyH),
    .rec_busy(rec_busy)
);
    
endmodule
