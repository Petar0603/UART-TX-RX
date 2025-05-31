class monitor extends uvm_monitor;
	`uvm_component_utils(monitor)
	uvm_analysis_port #(bit[7:0]) port;
	virtual uart_if uart_if_i;
	bit [7:0] data;

	function new(string path = "monitor", uvm_component parent = null);
		super.new(path, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		port = new("port", this);
		if(!uvm_config_db #(virtual uart_if)::get(this, "", "uart_if_i", uart_if_i)) begin
			`uvm_fatal(get_name(), "Couldn't connect the monitor to an interface!");
		end
	endfunction

	virtual task run_phase(uvm_phase phase);
		forever begin
			wait((uart_if_i.rx == 1'b0) || (uart_if_i.tx_req == 1'b1)); // wait for one of the operations to start
			if(uart_if_i.rx == 1'b0) begin
				wait(uart_if_i.rx_done == 1'b1); // wait for the flag
				this.data = uart_if_i.dout; // sample interface data
				`uvm_info(get_name(), $sformatf("Received data: %0b", this.data), UVM_NONE);
			end
			else if(uart_if_i.tx_req == 1'b1) begin
				repeat(8) @(posedge uart_if_i.s_tick); // middle of the start bit
				for(int i = 0; i < 8; i++) begin
					repeat(16) @(posedge uart_if_i.s_tick); // middle of data bit
					this.data[i] = uart_if_i.tx; // sample data bit
				end
				wait(uart_if_i.tx_done); // wait for the flag
				`uvm_info(get_name(), $sformatf("Transmitted data: %0b", this.data), UVM_NONE);
			end
			port.write(data);
		end
	endtask
endclass