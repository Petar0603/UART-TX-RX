interface uart_if();

	logic clk;
	logic rst;
	logic s_tick;
	logic tx_req;
	logic [7:0] din;
	logic tx;
	logic tx_done;
	logic rx;
	logic [7:0] dout;
	logic rx_done;

endinterface