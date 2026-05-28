`timescale 1ns / 1ps

module uart_ref (
    input  wire       sys_clk,
    input  wire       sys_rst,

    // --- Predictor Interface (From Testbench) ---
    input  wire       load_expected,  // Pulse HIGH for 1 cycle to load data
    input  wire [7:0] expected_data,  // The byte you are about to transmit

    // --- Checker Interface (From Testbench & RX) ---
    input  wire       check_actual,   // Pulse HIGH for 1 cycle to trigger compare
    input  wire [7:0] actual_data,    // Wired directly to the RX output

    // --- Output Flags ---
    output reg        pass_pulse,
    output reg        fail_pulse
);

    // This is the ONLY memory we need! Just one byte.
    reg [7:0] stored_byte;
    reg       has_data; // A safety flag to make sure we don't check empty data

    always @(posedge sys_clk or negedge sys_rst) begin
        if (!sys_rst) begin
            stored_byte <= 8'h00;
            has_data    <= 1'b0;
            pass_pulse  <= 1'b0;
            fail_pulse  <= 1'b0;
        end else begin
            
            // Default pulses to 0
            pass_pulse <= 1'b0;
            fail_pulse <= 1'b0;

            // 1. LOAD EXPECTED DATA
            if (load_expected) begin
                stored_byte <= expected_data;
                has_data    <= 1'b1;
                $display("[MODEL] Saved Expected Byte: %h", expected_data);
            end

            // 2. CHECK ACTUAL DATA
            else if (check_actual) begin
                if (!has_data) begin
                    $display("[MODEL ERROR] RX triggered a check, but model has no saved data!");
                    fail_pulse <= 1'b1;
                end 
                else if (actual_data === stored_byte) begin
                    $display("[SCOREBOARD PASS] Expected: %h | Got: %h", stored_byte, actual_data);
                    pass_pulse <= 1'b1;
                    has_data   <= 1'b0; // Clear it out for the next test
                end 
                else begin
                    $display("[SCOREBOARD FAIL] Expected: %h | Got: %h", stored_byte, actual_data);
                    fail_pulse <= 1'b1;
                    has_data   <= 1'b0;
                end
            end
            
        end
    end

endmodule