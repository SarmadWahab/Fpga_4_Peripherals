`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   23:25:41 07/11/2021
// Design Name:   ultrasonic_sensor_top
// Module Name:   D:/Spartan_6_Edge_Board/Git_us_updated/Top_tb.v
// Project Name:  Git_us_updated
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: ultrasonic_sensor_top
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

`include "G:\Git\git_us_updated\hcsr04_parameters.v"

module Top_tb;

	// Inputs
	reg Clk_i;
	reg Reset_i;
	reg Switch_i;
	reg Cm_or_inches_i;
	reg Echo_i;
	reg delay_trig_r;
	reg start_echo_counter_r;
	reg [20:0] counter_limit_r;
	reg [20:0] counter_r;

	// Outputs
	wire Trig_o;
	wire Tx_o;
	wire Unused_bit_o;

	// Instantiate the Unit Under Test (UUT)
	ultrasonic_sensor_top uut (
		.Clk_i(Clk_i), 
		.Reset_i(Reset_i), 
		.Switch_i(Switch_i), 
		.Cm_or_inches_i(Cm_or_inches_i), 
		.Echo_i(Echo_i), 
		.Trig_o(Trig_o), 
		.Tx_o(Tx_o), 
		.Unused_bit_o(Unused_bit_o)
	);

	always 
		begin
			Clk_i = 0;
			#10;
			Clk_i = 1;
			#10;
		end
		
	always @ (posedge Clk_i or negedge Reset_i)
		begin
			if(Reset_i == 1'b0)
				begin
					delay_trig_r <= 1'b0;
				end
			else
				begin
					delay_trig_r <= Trig_o;
				end
		end
		
	always @ (posedge Clk_i or negedge Reset_i)
		begin
			if(Reset_i == 1'b0)
				begin
					start_echo_counter_r <= 1'b0;
					counter_limit_r      <= 21'd0;
				end
			else
				begin
					if(delay_trig_r == 1'b1 && Trig_o == 1'b0)
						begin
							start_echo_counter_r <= 1'b1;
							counter_limit_r      <= counter_limit_r;
						end
					else if (delay_trig_r == 1'b0 && Trig_o == 1'b1)
						begin
							start_echo_counter_r <= 1'b0;
							counter_limit_r      <= $random;// 1cm to 400cm
						end
					else
						begin
							start_echo_counter_r <= start_echo_counter_r;
							if(counter_limit_r > 21'd2900 && counter_limit_r < 21'd1160000)
								begin
									counter_limit_r <= counter_limit_r;
								end
							else
								begin
									counter_limit_r <= 21'd1160000;
								end	
						end
				end
		end
		
		always @ (posedge Clk_i or negedge Reset_i)
			begin
				if(Reset_i == 1'b0)
					begin
						counter_r <= 21'd0;
					end
				else
					begin
						if(start_echo_counter_r == 1'b1 && counter_r < counter_limit_r)
							begin
								counter_r <= counter_r + 1'b1;
							end
						else if (delay_trig_r == 1'b0 && Trig_o == 1'b1 && counter_r == counter_limit_r)
							begin
								counter_r <= 21'd0;
							end
						else
							begin
								counter_r <= counter_r;
							end
					end
			end
			
			always @ (posedge Clk_i or negedge Reset_i)
				begin
					if(Reset_i == 1'b0)
						begin
							Echo_i <= 1'b0;
						end
					else
						begin
							if(counter_r < counter_limit_r && start_echo_counter_r == 1'b1 )
								begin
									Echo_i <= 1'b1;
								end
							else
								begin
									Echo_i  <= 1'b0;
								end
						end
				end
		
	initial begin
		// Initialize Inputs
		Clk_i = 0;
		Reset_i = 0;
		Switch_i = 0;
      Cm_or_inches_i = 0;
		// Wait 100 ns for global reset to finish
		#100;
		Reset_i = 1;
		Switch_i = 1;
        
		// Add stimulus here

	end
      
endmodule

