`include "uart_if.sv"

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "uart_pkg.sv"
import uart_pkg::*;

`timescale 1ns/1ps

// in the uart_pkg user can change macro values for:
// clock frequency, baud rate, number of iterations, maximum error count and reset duration

module uart_tb_top();

	uart_if tb_if();
	uart_top #(
		.CLK_FREQ(`CLK_FREQ),
		.BAUD_RATE(`BAUD_RATE)
	) dut(
		.clk(tb_if.clk),
		.rst(tb_if.rst),
		.tx_req(tb_if.tx_req),
		.din(tb_if.din),
		.tx(tb_if.tx),
		.tx_done(tb_if.tx_done),
		.rx(tb_if.rx),
		.dout(tb_if.dout),
		.rx_done(tb_if.rx_done),
		.s_tick(tb_if.s_tick)
	);

	initial begin
		tb_if.clk <= 1'b0;
	end
	always #5 tb_if.clk <= ~tb_if.clk; // if clk frequency is changed this also needs to be modified!

	initial begin
		uvm_top.set_report_verbosity_level(UVM_MEDIUM);
		uvm_top.set_report_max_quit_count(`MAX_ERROR_COUNT);
		uvm_config_db #(virtual uart_if)::set(null, "uvm_test_top.env.agn*", "uart_if_i", tb_if);
		run_test("test");
	end

	initial begin
		$dumpfile("dump.vcd");
		$dumpvars;
	end

endmodule