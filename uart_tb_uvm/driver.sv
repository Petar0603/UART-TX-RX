class driver extends uvm_driver #(transaction);
	`uvm_component_utils(driver);
	transaction t;
	virtual uart_if uart_if_i;
	uvm_blocking_put_port #(bit[7:0]) port; // sends data to scoreboard via TLM
	bit [7:0] rx_data;

	function new(string path = "driver", uvm_component parent = null);
		super.new(path, parent);
	endfunction

	function void display_op();
		if(this.t.operation == transmit) begin
			`uvm_info(get_name(), $sformatf("Performing transmission: %0b", this.t.din), UVM_NONE);
		end
		else begin
			`uvm_info(get_name(), "Performing reception.", UVM_NONE);
		end
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		port = new("port", this);
		if(!uvm_config_db #(virtual uart_if)::get(this, "", "uart_if_i", uart_if_i)) begin
			`uvm_fatal(get_name(), "Couldn't connect the driver to an interface!");
		end
	endfunction

	virtual task reset_phase(uvm_phase phase);
		phase.raise_objection(this);
		uart_if_i.tx_req <= 1'b0;
		uart_if_i.din <= 8'd0;
		uart_if_i.rx <= 1'b1;
		uart_if_i.rst <= 1'b1;
		#(`RST_DURATION);
		uart_if_i.rst <= 1'b0;
		`uvm_info(get_name(), "Reset done.", UVM_NONE);
		phase.drop_objection(this);
	endtask

	task drive_rx();
		repeat(16) @(posedge uart_if_i.s_tick); // start bit duration
		for (int i = 0; i < 8; i++) begin
			this.t.randomize_rx(); // generate bit
			uart_if_i.rx <= this.t.rx; // drive to interface
			repeat(16) @(posedge uart_if_i.s_tick); // one bit duration
		end
		uart_if_i.rx <= 1'b1; // stop bit
	endtask

	task sample_rx();
		repeat(24) @(posedge uart_if_i.s_tick); // middle of first data bit (start bit + 1.5 bit times)
		for (int i = 0; i < 8; i++) begin
			this.rx_data[i] = uart_if_i.rx; // sample the rx line
			repeat(16) @(posedge uart_if_i.s_tick); // wait one bit duration
		end
		port.put(rx_data);
		`uvm_info(get_name(), $sformatf("Data to be received: %0b", rx_data), UVM_NONE);
	endtask

	virtual task run_phase(uvm_phase phase);
		forever begin
			seq_item_port.get_next_item(t);

			display_op();

			uart_if_i.din <= this.t.din;
			uart_if_i.rx <= this.t.rx;
			uart_if_i.tx_req <= this.t.tx_req;

			if(t.operation == transmit) begin
				repeat(5) @(posedge uart_if_i.clk);
				uart_if_i.tx_req <= 1'b0; // reset tx_req after it is set
				port.put(this.t.din);
				wait(uart_if_i.tx_done == 1'b1); // wait for the flag
			end
			else if(t.operation == receive) begin
				fork
					drive_rx();
					sample_rx();
				join
				wait(uart_if_i.rx_done == 1'b1); // wait for rx_done flag
			end

			repeat(5) @(posedge uart_if_i.clk); // timeout for next iteration
			seq_item_port.item_done();
		end
	endtask
endclass