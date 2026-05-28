`define WORD_LEN 8 // Number of bits in a word
`define XTAL_CLK 50_000_000 // 50MHz (frequency of the crystal oscillator feeding the UART clock)
`define BAUD 2400 // Default baud rate for UART communication
`define CLK_DIV ( `XTAL_CLK / (16 * `BAUD * 2) ) // Clock divider for UART baud rate generation
`define CW $clog2(`CLK_DIV) // width of internal counters (must be large enough to count up to `CLK_DIV)

