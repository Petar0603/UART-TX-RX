module baud_generator
#(
	parameter CLK_FREQ = 100_000_000,
	parameter BAUD_RATE = 9600
)
(
	input clk,
	input rst,
	output s_tick
);

	reg[9:0] final_count = (CLK_FREQ / (BAUD_RATE * 16)) - 1; // after this many clk posedges generate s_tick pulse (for only one clk cycle)
	reg [10:0] current_count = 11'd0; // counts clk posedges
	reg s_tick_temp = 1'b0;

	always@(posedge clk, posedge rst) begin
		if(rst) begin
			s_tick_temp <= 1'b0;
			current_count <= 11'd0;
		end
		else if(current_count == final_count) begin
			s_tick_temp <= 1'b1; // pulse (16 of them are equal to duration of one baud!)
			current_count <= 11'd0;
		end
		else begin
			s_tick_temp <= 1'b0;
			current_count <= current_count + 1;
		end
	end

	assign s_tick = s_tick_temp;

endmodule