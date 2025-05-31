class generator;

	mailbox #(transaction) gen2drv;
	int count;
	transaction tr;
	event scoreboard_done, generator_done;

	function new(mailbox #(transaction) gen2drv, int count, event scoreboard_done, generator_done);
		this.gen2drv = gen2drv;
		this.count = count;
		this.scoreboard_done = scoreboard_done;
		this.generator_done = generator_done;
	endfunction

	function void display_op();
		if(tr.operation == transmit) 
			$display("[GEN] : TRANSMITTING DATA \t DIN : %0b \t | \t TIME : %0t", tr.din, $time);
		else
			$display("[GEN] : RECEIVING DATA \t | \t TIME : %0t", $time);
	endfunction

	task run();
		tr = new();
		repeat(count) begin
			assert(tr.randomize) else begin
				$display("[GEN] : RANDOMIZATION FAILED! \t | \t TIME : %0t", $time);
			end
			display_op();
			gen2drv.put(tr.copy);
			@(scoreboard_done); // wait for the scoreboard to finish comparison of data
		end
		->generator_done;
	endtask
endclass