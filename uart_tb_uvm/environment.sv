class environment extends uvm_env;
	`uvm_component_utils(environment)
	scoreboard sco;
	agent agn;

	function new(string path = "environment", uvm_component parent = null);
		super.new(path, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		sco = scoreboard::type_id::create("sco", this);
		agn = agent::type_id::create("agn", this);
	endfunction

	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		agn.mon.port.connect(sco.monitor_imp);
		agn.drv.port.connect(sco.driver_imp);
	endfunction
endclass