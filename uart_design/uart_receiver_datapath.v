module uart_receiver_datapath
(
	input clk, // rising edge
	input rst, // asynchronous reset
	input rx,

	// shift register to store received data
	input sreg_en,

	// s_tick counter signals
	input s_tick_counter_en,
	input s_tick_counter_clr,
	output s_tick_counter_s7, // state 7 indicator
	output s_tick_counter_s15, // state 15 indicator
	output s_tick_counter_s23,

	// data counter signals
	input data_counter_en,
	input data_counter_clr,
	output data_counter_s7, // state 7 indicator

	output [7:0] dout // parallel output
);

	reg [7:0] sreg = 8'h00;
	reg [4:0] s_tick_counter = 5'd0; // 16* oversampling so 4 bits are enough
	reg [2:0] data_counter = 3'b000; // 8 bits of data so 8 bits in data counter



	always@(posedge clk, posedge rst) begin
		if(rst) begin
			sreg <= 8'h00;
		end
		else if(sreg_en) begin
			sreg <= {rx, sreg[7:1]}; // shift
		end
	end



	always@(posedge clk, posedge rst) begin
		if(rst) begin
			s_tick_counter <= 5'd0;
		end
		else if(s_tick_counter_clr) begin
			s_tick_counter <= 5'd0;
		end
		else if(s_tick_counter_en) begin
			s_tick_counter <= s_tick_counter + 1;
		end
	end
	assign s_tick_counter_s7 = (s_tick_counter == 7)? 1'b1 : 1'b0;
	assign s_tick_counter_s15 = (s_tick_counter == 15)? 1'b1 : 1'b0;
	assign s_tick_counter_s23 = (s_tick_counter == 23)? 1'b1 : 1'b0;



	always@(posedge clk, posedge rst) begin
		if(rst) begin
			data_counter <= 3'b000;
		end
		else if(data_counter_clr) begin
			data_counter <= 3'b000;
		end
		else if(data_counter_en) begin
			data_counter <= data_counter + 1;
		end
	end
	assign data_counter_s7 = (data_counter == 7)? 1'b1 : 1'b0;



	assign dout = sreg;

endmodule