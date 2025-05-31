class monitor;

	virtual uart_if mon_if;

	mailbox #(bit [7:0]) mon2sco;

	bit [7:0] data;

	function new(mailbox #(bit [7:0]) mon2sco, virtual uart_if mon_if);
		this.mon2sco = mon2sco;
		this.mon_if = mon_if;
	endfunction

	task run();
		forever begin
			wait((mon_if.rx == 1'b0) || (mon_if.tx_req == 1'b1)); // wait for one of the operations to start
			if(mon_if.rx == 1'b0) begin
				wait(mon_if.rx_done == 1'b1); // wait for the flag
				this.data = mon_if.dout; // sample interface data
				$display("[MON] : DOUT FROM RECEPTION: %0b \t | \t TIME : %0t", this.data, $time);
			end
			else if(mon_if.tx_req == 1'b1) begin
				repeat(8) @(posedge mon_if.s_tick); // middle of the start bit
				for(int i = 0; i < 8; i++) begin
					repeat(16) @(posedge mon_if.s_tick); // middle of data bit
					this.data[i] = mon_if.tx; // sample data bit
				end
				wait(mon_if.tx_done); // wait for the flag
				$display("[MON] : TRANSMITTED DATA: %0b \t | \t TIME : %0t", this.data, $time);
			end
			mon2sco.put(data);
		end
	endtask

endclass