module uart_receiver
(
	input clk,
	input rst,
	input s_tick,

	input rx,
	output [7:0] dout,
	output rx_done
);

	// interconnections between datapath and control unit
	wire sreg_en_i;
	wire s_tick_counter_en_i;
	wire s_tick_counter_clr_i;
	wire s_tick_counter_s7_i;
	wire s_tick_counter_s15_i;
	wire s_tick_counter_s23_i;
	wire data_counter_en_i;
	wire data_counter_clr_i;
	wire data_counter_s7_i; 

	uart_receiver_datapath rx_datapath
	(
		.clk(clk),
		.rst(rst),
		.rx(rx),
		.dout(dout),
		.sreg_en(sreg_en_i),
		.s_tick_counter_en(s_tick_counter_en_i),
		.s_tick_counter_clr(s_tick_counter_clr_i),
		.s_tick_counter_s7(s_tick_counter_s7_i),
		.s_tick_counter_s15(s_tick_counter_s15_i),
		.s_tick_counter_s23(s_tick_counter_s23_i),
		.data_counter_en(data_counter_en_i),
		.data_counter_clr(data_counter_clr_i),
		.data_counter_s7(data_counter_s7_i)
	);

	uart_receiver_control_unit rx_control_unit
	(
		.clk(clk),
		.rst(rst),
		.s_tick(s_tick),
		.rx(rx),
		.rx_done(rx_done),
		.sreg_en(sreg_en_i),
		.s_tick_counter_en(s_tick_counter_en_i),
		.s_tick_counter_clr(s_tick_counter_clr_i),
		.s_tick_counter_s7(s_tick_counter_s7_i),
		.s_tick_counter_s15(s_tick_counter_s15_i),
		.s_tick_counter_s23(s_tick_counter_s23_i),
		.data_counter_en(data_counter_en_i),
		.data_counter_clr(data_counter_clr_i),
		.data_counter_s7(data_counter_s7_i)
	);

endmodule