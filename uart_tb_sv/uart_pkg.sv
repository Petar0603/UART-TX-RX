`ifndef UART_PKG
`define UART_PKG

package uart_pkg;
	`include "transaction.sv"
	`include "generator.sv"
	`include "driver.sv"
	`include "monitor.sv"
	`include "scoreboard.sv"
	`include "environment.sv"
endpackage

`endif