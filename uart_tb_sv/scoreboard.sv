class scoreboard;

	mailbox #(bit [7:0]) mon2sco, drv2sco;
	event scoreboard_done;

	bit [7:0] driver_data, monitor_data;
	int error_count = 0;

	function new(mailbox #(bit [7:0]) mon2sco, drv2sco, event scoreboard_done);
		this.mon2sco = mon2sco;   
		this.drv2sco = drv2sco;
		this.scoreboard_done = scoreboard_done;
	endfunction

	task compare;
		if(driver_data == monitor_data) begin
			$display("[SCO] : DRIVER AND MONITOR DATA MATCHES! \t | \t TIME : %0t", $time); 
		end
		else begin
			$display("[SCO] : DRIVER AND MONITOR DATA DOESN'T MATCH! \t | \t TIME : %0t", $time);
			error_count++;
		end
	endtask

	task display_error_count;
		$display("[SCO] : CURRENT ERROR COUNT = %0d \t | \t TIME : %0t", error_count, $time);
		$display("-----------------------------------------------------");
	endtask

	task run;
		forever begin
			drv2sco.get(driver_data);
			mon2sco.get(monitor_data);
			compare();
			display_error_count();
			->scoreboard_done;
		end
	endtask

endclass