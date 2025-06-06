class agent extends uvm_agent;
	`uvm_component_utils(agent)
	uvm_sequencer #(transaction) seq;
	monitor mon;
	driver drv;

	function new(string path = "agent", uvm_component parent = null);
		super.new(path, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		mon = monitor::type_id::create("mon", this);
		drv = driver::type_id::create("drv", this);
		seq = uvm_sequencer #(transaction)::type_id::create("seq", this);
	endfunction

	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		drv.seq_item_port.connect(seq.seq_item_export);
	endfunction
endclass