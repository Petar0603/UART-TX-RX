module uart_receiver_control_unit
(
	input clk, // rising edge
	input rst, // asynchronous reset
	input s_tick, // oversampling pulses
	input rx, // receiver line

	input s_tick_counter_s7, // 8 ticks counted indicator
	input s_tick_counter_s15, // 16 ticks counted indicator
	input s_tick_counter_s23, // 24 ticks counted indicator

	input data_counter_s7, // 8 data bits counted indicator

	// control signal outputs
	output sreg_en,

	output s_tick_counter_en,
	output s_tick_counter_clr,

	output data_counter_en,
	output data_counter_clr,

	output rx_done
);

	parameter IDLE = 2'b00, START = 2'b01, DATA = 2'b10, STOP = 2'b11;
	reg [1:0] current_state = IDLE;
	reg [1:0] next_state;

	// temporary variables
	reg rx_done_temp = 1'b0;
	reg sreg_en_temp = 1'b0;
	reg s_tick_counter_en_temp = 1'b0;
	reg s_tick_counter_clr_temp = 1'b0;
	reg data_counter_en_temp = 1'b0;
	reg data_counter_clr_temp = 1'b0;

	always@(posedge clk, posedge rst) begin
		if(rst) begin
			current_state <= IDLE;
		end
		else begin
			current_state <= next_state;
		end
	end

	always@(current_state, rx, s_tick, s_tick_counter_s7, s_tick_counter_s15, s_tick_counter_s23, data_counter_s7) begin

		next_state = current_state;

		sreg_en_temp = 1'b0;
		s_tick_counter_en_temp = 1'b0;
		s_tick_counter_clr_temp = 1'b0;
		data_counter_en_temp = 1'b0;
		data_counter_clr_temp = 1'b0;
		rx_done_temp = 1'b0;

		case(current_state)

			IDLE: begin

				if(!rx) begin // start bit on rx line
					s_tick_counter_clr_temp = 1'b1;
					next_state = START;
				end

			end

			START: begin

				if(s_tick) begin
					if(s_tick_counter_s7) begin // middle of the start bit
						s_tick_counter_clr_temp = 1'b1;
						data_counter_clr_temp = 1'b1;
						next_state = DATA;
					end
					else begin
						s_tick_counter_en_temp = 1'b1;
					end
				end

			end

			DATA: begin

				if(s_tick) begin
					if(s_tick_counter_s15) begin // since it started from the middle of the start bit, after every 16 pulses we are on the middle of the data bit
						sreg_en_temp = 1'b1;
						s_tick_counter_clr_temp = 1'b1;
						if(data_counter_s7) begin
							data_counter_clr_temp = 1'b1;
							next_state = STOP;
						end
						else begin
							data_counter_en_temp = 1'b1;
						end
					end 
					else begin
						s_tick_counter_en_temp = 1'b1;
					end
				end
				
			end

			STOP: begin

				if(s_tick) begin
					if(s_tick_counter_s23) begin
						s_tick_counter_clr_temp = 1'b1;
						rx_done_temp = 1'b1;
						next_state = IDLE;
					end
					else begin
						s_tick_counter_en_temp = 1'b1;
					end
				end

			end

		endcase
	end

	assign rx_done = rx_done_temp;
	assign sreg_en = sreg_en_temp;
	assign s_tick_counter_en = s_tick_counter_en_temp;
	assign s_tick_counter_clr = s_tick_counter_clr_temp;
	assign data_counter_en = data_counter_en_temp;
	assign data_counter_clr = data_counter_clr_temp;

endmodule