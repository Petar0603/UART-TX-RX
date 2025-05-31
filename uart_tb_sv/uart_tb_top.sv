`include "uart_if.sv"
`include "uart_pkg.sv"

`timescale 1ns / 1ps

import uart_pkg::*;

module uart_tb_top;

	int uart_iterations = 10;

	uart_if tb_if();

	environment env;

	uart_top dut(
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

	task pre_test;
		tb_if.rst <= 1;
		repeat(5) @(posedge tb_if.clk);
		tb_if.rst <= 0;
		@(posedge tb_if.clk);
	endtask

	initial begin
		tb_if.clk <= 0;
	end
	always #5 tb_if.clk = ~tb_if.clk;

	initial begin
		env = new(uart_iterations, tb_if);
	end

	initial begin
		pre_test();
		env.run();
	end

endmodule