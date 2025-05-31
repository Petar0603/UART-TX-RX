// this is an uart module with a separate receiver and a transmitter
// it also includes a baud generator with 16x oversampling (in parameter list user can configure baud rate and clock frequency)
module uart_top
#(
	parameter CLK_FREQ = 100_000_000, // default values
	parameter BAUD_RATE = 9600
)
(
	input clk,
	input rst,

	input tx_req, // transmission request, when high, perform transmission
	input [7:0] din, // data to be transmitted
	output tx, // transmission line
	output tx_done, // transmission completed flag

	input rx, // reception line
	output [7:0] dout, // received data
	output rx_done, // reception completed flag

	output s_tick // FOR TESTBENCH!
);

	wire s_tick_i;
	assign s_tick = s_tick_i;

	uart_receiver uart_rx
	(
		.clk(clk),
		.rst(rst),
		.s_tick(s_tick_i), // input from baud generator
		.rx(rx),
		.dout(dout),
		.rx_done(rx_done)
	);

	uart_transmitter uart_tx
	(
		.clk(clk),
		.rst(rst),
		.tx_req(tx_req),
		.din(din),
		.s_tick(s_tick_i), // input from baud generator
		.tx(tx),
		.tx_done(tx_done)
	);

	baud_generator 
	#(
		.CLK_FREQ(CLK_FREQ),
		.BAUD_RATE(BAUD_RATE)
	)
	baud_generator_inst
	(
		.clk(clk),
		.s_tick(s_tick_i), // output for tx and rx modules
		.rst(rst)
	);

endmodule