`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: DIY Projects
// Engineer: Sarmad Wahab
//
// Create Date: 25.06.2021
// Design Name: PWM generation for DC Servo Motor MG995
// Module Name: top_pwm_tb
// Target Device: Xilinx Spartan 6
// Tool versions: Design ISE 14.7
////////////////////////////////////////////////////////////////////////////////

`include "give_your_local_location\mg995_parameters.v"

module top_pwm_tb;

	// Inputs
	reg Clk_i;
	reg Reset_i;
	reg [1:0] Sel_i;

	// Outputs
	wire Pwm_o;
	wire Tx_o;
          
   reg pwm_delay_r;
	reg active_duty_cycle_region_r;
	reg [16:0] duty_cycle_counter_r;
	reg [19:0] pwm_period_counter_r;
	reg pwm_period_region_r;
	// Instantiate the Unit Under Test (UUT)
	top_pwm uut (
		.Clk_i(Clk_i), 
		.Reset_i(Reset_i), 
		.Sel_i(Sel_i), 
		.Pwm_o(Pwm_o), 
		.Tx_o(Tx_o)
	);

   always
     begin
	Clk_i = 0;
	#10;
	Clk_i = 1;
	#10;
     end

  	initial begin
		// Initialize Inputs
		Reset_i = 0;
		Sel_i = 0;

		// Wait 100 ns for global reset to finish
		#100;
      Reset_i = 1;
	   Sel_i   = 3;
		//#20500500;
		#41000;
		Sel_i   = 1;
		// Add stimulus here

	end // initial begin

   always @ (posedge Clk_i)
		begin
			if(Reset_i == 1'b0)
				begin
					pwm_delay_r <= 1'b0;
				end
			else
				begin
					pwm_delay_r <= Pwm_o;
				end
		end
   always @ (posedge Clk_i)
		begin
			if(Reset_i == 1'b0)
				begin
					active_duty_cycle_region_r <= 1'b0;
				end
			else
				begin
					if(Pwm_o == 1'b1 && pwm_delay_r == 1'b0)
						begin
							active_duty_cycle_region_r <= 1'b1;
						end
					else if (Pwm_o == 1'b0 && pwm_delay_r == 1'b1)
						begin
							active_duty_cycle_region_r <= 1'b0;
						end
					else
						begin
							active_duty_cycle_region_r <= active_duty_cycle_region_r;
						end
				end
		end
		
	always @ (posedge Clk_i)
		begin
			if(Reset_i == 1'b0)
				begin
					pwm_period_region_r <= 1'b0;
				end
			else
				begin
					if(Pwm_o == 1'b1 && pwm_delay_r == 1'b0 && pwm_period_region_r == 1'b0)
						begin
							pwm_period_region_r <= 1'b1;
						end
					else if (Pwm_o == 1'b1 && pwm_delay_r == 1'b0 && pwm_period_region_r == 1'b1)
						begin
							pwm_period_region_r <= 1'b0;
						end
					else
						begin
							pwm_period_region_r <= pwm_period_region_r;
						end
				end
		end
  
   always @ (posedge Clk_i)
		begin
			if(Reset_i == 1'b0)
				begin
					duty_cycle_counter_r <= 17'd0;
				end
			else
				begin
					if(active_duty_cycle_region_r == 1'b1)
						begin
							duty_cycle_counter_r <= duty_cycle_counter_r + 1'b1;
						end
					else
						begin
							duty_cycle_counter_r <= 17'd0;
						end
				end
		end
		
	always @ (posedge Clk_i)
		begin
			if(Reset_i == 1'b0)
				begin
					pwm_period_counter_r <= 20'd0;
				end
			else
				begin
					if(pwm_period_region_r == 1'b1)
						begin
							pwm_period_counter_r <= pwm_period_counter_r + 1'b1;
						end
					else
						begin
							pwm_period_counter_r <= 20'd0;
						end
				end
		end
    always @(*)
		begin
			if(Pwm_o == 1'b0 && pwm_delay_r == 1'b1)
				begin
					if(duty_cycle_counter_r == 17'd24999 && Sel_i == 1)
						begin
							$display("Duty Cycle is 0.5ms");
						end
					else if (duty_cycle_counter_r == 17'd74999 && Sel_i == 2)
						begin
							$display("Duty Cycle is 1.5ms");
						end
					else if (duty_cycle_counter_r == 17'd124999 && Sel_i == 3)
						begin
							$display("Duty Cycle is 2.5ms");
						end
					else
						begin
							$display("Duty cycle is corrupted !!!");
						end
				end
			else
				begin
				end
		end
      
		always @ (*) // This block can be ommitted as whenever we have switch from 0 to 90 or 180 angle period will be corrupted !!!
			begin
				if(Pwm_o == 1'b1 && pwm_delay_r == 1'b0 && pwm_period_region_r == 1'b1)
					begin
						if (pwm_period_counter_r == 20'd1000000)
							begin
								$display("Time period is 20ms");
							end
						else
							begin
								$display("Time period is corrupted");
							end
					end
				else
					begin
					end
				end


endmodule					
