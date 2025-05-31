class driver;

	virtual uart_if drv_if;

	mailbox #(transaction) gen2drv;
	mailbox #(bit[7:0]) drv2sco;
	transaction tr;

	bit [7:0] rx_data; // data that is sent on the rx line serialy

	function new(mailbox #(transaction) gen2drv, mailbox #(bit[7:0]) drv2sco, virtual uart_if drv_if);
		this.gen2drv = gen2drv;
		this.drv2sco = drv2sco;
		this.drv_if = drv_if;
	endfunction

	task drive_rx();
		repeat(16) @(posedge drv_if.s_tick); // start bit
		for (int i = 0; i < 8; i++) begin
			tr.randomize_rx();
			drv_if.rx <= tr.rx;
			repeat(16) @(posedge drv_if.s_tick); // full bit duration
		end
		drv_if.rx <= 1'b1; // stop bit
	endtask

	task sample_rx();
		repeat(24) @(posedge drv_if.s_tick); // wait 1.5 bit times to reach center of first bit
		for (int i = 0; i < 8; i++) begin
			rx_data[i] = drv_if.rx;
			repeat(16) @(posedge drv_if.s_tick); // next bit center
		end
		$display("[DRV] : DATA TO BE RECEIVED: %0b \t | \t TIME : %0t", rx_data, $time);
		drv2sco.put(rx_data);
	endtask

	task perform_transmit_or_receive;

		drv_if.din <= tr.din;
		drv_if.rx <= tr.rx;
		drv_if.tx_req <= tr.tx_req;

		if(tr.operation == transmit) begin
			repeat(5) @(posedge drv_if.clk);
			drv_if.tx_req <= 1'b0; // reset tx_req after it is set
			drv2sco.put(tr.din);
			$display("[DRV] : DATA TO BE TRANSMITTED : %0b \t | \t TIME : %0t", tr.din, $time);
			wait(drv_if.tx_done == 1'b1); // wait for the flag
		end
		else if(tr.operation == receive) begin
			fork
				drive_rx();
				sample_rx();
			join
			wait(drv_if.rx_done == 1'b1);
		end
		repeat(5) @(posedge drv_if.clk); // timeout for next iteration

	endtask

	task display_op;
		if(tr.operation == transmit) begin
			$display("[DRV] : PERFORMING TRANSMISSION \t DIN : %0b \t | \t TIME : %0t", tr.din, $time);  
		end
		else begin
			$display("[DRV] : PERFORMING RECEPTION \t | \t TIME : %0t", $time);
		end
	endtask

	task run();
		forever begin
			gen2drv.get(tr);
			display_op();
			perform_transmit_or_receive();
		end 
	endtask

endclass