typedef enum bit {transmit = 1'b0, receive = 1'b1} operation_type;

class transaction extends uvm_sequence_item;

	randc operation_type operation; // bit to generate operation type
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

	function new(string path = "transaction");
		super.new(path);
	endfunction

	`uvm_object_utils_begin(transaction) // registering to a factory (for clone method)
		`uvm_field_enum(operation_type, operation, UVM_DEFAULT)
		`uvm_field_int(din, UVM_DEFAULT)
		`uvm_field_int(rx, UVM_DEFAULT)
		`uvm_field_int(tx_req, UVM_DEFAULT)
		`uvm_field_int(tx, UVM_DEFAULT)
		`uvm_field_int(tx_done, UVM_DEFAULT)
		`uvm_field_int(rx_done, UVM_DEFAULT)
		`uvm_field_int(dout, UVM_DEFAULT)
	`uvm_object_utils_end

endclass