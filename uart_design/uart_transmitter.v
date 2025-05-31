module uart_transmitter
(

	input clk,
	input rst,
	input tx_req,
	input [7:0] din,
	input s_tick,

	output tx,
	output tx_done

);

	parameter IDLE = 2'b00, START = 2'b01, DATA = 2'b10, STOP = 2'b11; // transmitter states
	reg [1:0] current_state = IDLE;
	reg [1:0] next_state;

	reg [3:0] s_tick_counter = 4'd0; // counts s_tick pulses
	reg [7:0] sreg = 8'd0; // shift register
	reg [2:0] data_counter = 3'b000; // counts data bits

	reg tx_done_temp = 1'b0;
	reg tx_temp = 1'b1;

	always@(posedge clk, posedge rst) begin
		if(rst) begin
			current_state <= IDLE;
		end
		else begin
			current_state <= next_state;
		end
	end

	always@(current_state, s_tick, tx_req) begin

		next_state = current_state;

		tx_done_temp = 1'b0;

		case(current_state)

			IDLE: begin

				sreg = 8'd0;
				s_tick_counter = 4'd0;
				data_counter = 3'b000;
				tx_temp = 1'b1; // transmission line in idle state is high

				if(tx_req) begin
					sreg = din; // sample din
					s_tick_counter = 4'd0; // reset
					tx_temp = 1'b0; // start bit
					next_state = START;
				end

			end

			START: begin

				if(s_tick) begin
					if(s_tick_counter == 4'd15) begin // after 16 s_ticks
						s_tick_counter = 4'd0;
						data_counter = 3'b000; // reset data counter
						tx_temp = sreg[0]; // put the first bit on tx line
						sreg = sreg >> 1; // shift for next iteration
						next_state = DATA;
					end
					else begin
						s_tick_counter = s_tick_counter + 1;
					end
				end

			end

			DATA: begin

				if(s_tick) begin
					if(s_tick_counter == 4'd15) begin // after 16 s_ticks
						s_tick_counter = 4'd0;
						tx_temp = sreg[0]; // put the next bit on tx line
						sreg = sreg >> 1; // shift for next iteration
						if(data_counter == 3'b111) begin
							tx_temp = 1'b1; // stop bit
							next_state = STOP;
						end
						else begin
							data_counter = data_counter + 1;
						end
					end
					else begin
						s_tick_counter = s_tick_counter + 1;
					end
				end

			end

			STOP: begin

				if(s_tick) begin
					if(s_tick_counter == 15) begin
						s_tick_counter = 4'd0;
						tx_done_temp = 1'b1; // set the flag high
						next_state = IDLE;
					end
				end
				else begin
					s_tick_counter = s_tick_counter + 1;
				end
			end

		endcase
	end

	assign tx = tx_temp;
	assign tx_done = tx_done_temp;

endmodule