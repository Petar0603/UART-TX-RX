class sequence1 extends uvm_sequence #(transaction);
	`uvm_object_utils(sequence1)
	transaction t;
	int count = 0; // only tracks the current no. of iteration

	function new(string path = "sequence1");
		super.new(path);
	endfunction

	function void display_op();
		if(this.t.operation == receive) begin
			`uvm_info(get_name(), "Receiving data.", UVM_NONE);
		end
		else begin
			`uvm_info(get_name(), $sformatf("Transmitting data %0b", this.t.din), UVM_NONE);
		end
	endfunction

	virtual task body();
		#(`RST_DURATION); // wait for reset_phase of driver to finish
		t = transaction::type_id::create("t");
		repeat(`NUM_ITERATIONS) begin
			start_item(t);
			if (!t.randomize()) begin
				`uvm_error(get_name(), "Randomization failed!");
			end
			`uvm_info(get_name(), $sformatf("Iteration no. %0d ", count), UVM_NONE);
			display_op();
			count++;
			finish_item(t);
		end
	endtask
endclass