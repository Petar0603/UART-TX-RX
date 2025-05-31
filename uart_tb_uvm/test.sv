class test extends uvm_test;
	`uvm_component_utils(test)
	sequence1 seq1;
	environment env;

	function new(string name = "test", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		seq1 = sequence1::type_id::create("seq1");
		env = environment::type_id::create("env", this);
	endfunction

	virtual function void end_of_elaboration_phase(uvm_phase phase);
		super.end_of_elaboration_phase(phase);
		uvm_top.print_topology(); // prints the hierarchy
	endfunction

	virtual task run_phase(uvm_phase phase);
		phase.raise_objection(this);
		seq1.start(env.agn.seq);
		phase.drop_objection(this);
	endtask
endclass