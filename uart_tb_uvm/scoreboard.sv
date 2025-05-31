class scoreboard extends uvm_scoreboard;
	`uvm_component_utils(scoreboard)
	uvm_analysis_imp #(bit[7:0], scoreboard) monitor_imp;
	uvm_blocking_put_imp #(bit[7:0], scoreboard) driver_imp;
	bit [7:0] monitor_data, driver_data;

	function new(string path = "scoreboard", uvm_component parent = null);
		super.new(path, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		monitor_imp = new("monitor_imp", this);
		driver_imp = new("driver_imp", this);
	endfunction

	function void compare();
		if(this.driver_data == this.monitor_data) begin
			`uvm_info(get_name(), "Data match!", UVM_NONE);
		end
		else begin
			`uvm_error(get_name(), "Data mismatch!");
		end
	endfunction

	virtual function void write(bit [7:0] monitor_data);
		this.monitor_data = monitor_data;
		compare();
		`uvm_info(get_name(), $sformatf("Data received from monitor: %0b.", this.monitor_data), UVM_DEBUG);
	endfunction

	virtual function void put(bit [7:0] driver_data);
		this.driver_data = driver_data;
		`uvm_info(get_name(), $sformatf("Data received from driver: %0b.", this.driver_data), UVM_DEBUG);
	endfunction

endclass