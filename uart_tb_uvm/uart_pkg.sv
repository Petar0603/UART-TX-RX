`ifndef UART_PKG
`define UART_PKG

`include "uvm_macros.svh"

`define NUM_ITERATIONS 10 // modify preferred number of iterations
`define MAX_ERROR_COUNT 1 // after this many uvm_error-s, call $finish system task
`define RST_DURATION 50 // for how many ns to remain in reset_phase of driver
`define CLK_FREQ 100_000_000
`define BAUD_RATE 1_500_000 // high baud rate because of EDA Playground's wavefrom viewer

package uart_pkg;
	import uvm_pkg::*;
	`include "transaction.sv"
	`include "sequence1.sv"
	`include "driver.sv"
	`include "monitor.sv"
	`include "agent.sv"
	`include "scoreboard.sv"
	`include "environment.sv"
	`include "test.sv"
endpackage

`endif