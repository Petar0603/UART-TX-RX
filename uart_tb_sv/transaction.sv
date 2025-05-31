typedef enum bit {transmit = 1'b0, receive = 1'b1} operation_type;

class transaction;

	rand operation_type operation; // bit to generate operation type
	rand bit [7:0] din; // data to be transmitted
	rand bit rx; // generate serial input values
	rand bit tx_req; // when transmission is selected set it to logic 1

	bit tx;
	bit tx_done;
	bit rx_done;
	bit [7:0] dout;

	constraint rx_c {
		(operation == transmit) -> rx == 1'b1; // rx is always high when transmission is selected
		(operation == receive) -> rx == 1'b0; // generating start bit when reception is performed
	}

	constraint tx_req_c {
		(operation == transmit) -> tx_req == 1'b1; // transmission request high
		(operation == receive) -> tx_req == 1'b0;
	}

	function void randomize_rx;
	   this.rx = $urandom_range(0,1); // function to generate random rx values when receiving data
	endfunction

	function transaction copy(); // deep copy of the transaction
		copy = new();
		copy.operation = this.operation;
		copy.din = this.din;
		copy.tx_req = this.tx_req;
		copy.rx = this.rx;
		copy.tx = this.tx;
		copy.tx_done = this.tx_done;
		copy.rx_done = this.rx_done;
		copy.dout = this.dout;
	endfunction

endclass