class environment;

	generator gen;
	driver drv;
	monitor mon;
	scoreboard sco;

	mailbox #(transaction) gen2drv;
	mailbox #(bit [7:0]) mon2sco, drv2sco;

	event scoreboard_done, generator_done;

	function new(input int count, virtual uart_if env_if);

		gen2drv = new();
		drv2sco = new();
		mon2sco = new();

		gen = new(gen2drv, count, scoreboard_done, generator_done);
		drv = new(gen2drv, drv2sco, env_if);
		mon = new(mon2sco, env_if);
		sco = new(mon2sco, drv2sco, scoreboard_done);

	endfunction

	task test;
		fork
			gen.run();
			drv.run();
			mon.run();
			sco.run();
		join_none
	endtask

	task post_test;
		@(generator_done);
		$finish;
	endtask

	task run;
		test();
		post_test();
	endtask

endclass