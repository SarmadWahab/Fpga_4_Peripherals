////////////////////////////////////////////////////////////////////////////////
// Company: DIY Projects
// Engineer: Sarmad Wahab
//
// Create Date: 01.07.2021
// Design Name: PWM generation for DC Motor MG33
// Module Name: pwm_top_tb
// Target Device: Xilinx Spartan 6
// Tool versions: Design ISE 14.7
////////////////////////////////////////////////////////////////////////////////



`timescale 1ns / 1ps
`include "give_your_local_location\mg33_parameters.v"


module pwm_top_tb;

	// Inputs
	reg Clk_i;
	reg Reset_i;
	reg [1:0] Sel_i;

	// Outputs
	wire Pwm_o;
	reg  pwm_delay_r;
	reg  pwm_active_region_r;
	
	reg [3:0] pwm_counter_r;

	// Instantiate the Unit Under Test (UUT)
	pwm_top uut (
		.Clk_i(Clk_i), 
		.Reset_i(Reset_i), 
		.Sel_i(Sel_i), 
		.Pwm_o(Pwm_o)
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
		Clk_i = 0;
		Reset_i = 0;
		Sel_i = 0;
		#100;
      Reset_i = 1;
		Sel_i   = 1;      // 20%
		#500;
		Sel_i   = 2;      // 50%
      #2000;
      Sel_i   = 3;      // 100%
		#100;
		Sel_i   = 1;
		// Add stimulus here

	end

always @ (posedge Clk_i or negedge Reset_i)
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
	

always @ (posedge Clk_i or negedge Reset_i)
		begin
			if(Reset_i == 1'b0)
				begin
					pwm_active_region_r <= 1'b0;
				end
			else
				begin
					if(Pwm_o == 1'b1 && pwm_delay_r == 1'b0)
						begin
							pwm_active_region_r <= 1'b1;
						end
					else if (Pwm_o == 1'b0 && pwm_delay_r == 1'b1)
						begin
							pwm_active_region_r <= 1'b0;
						end
					else
						begin
							pwm_active_region_r <= pwm_active_region_r;
						end
					
				end
		end
	

always @ (posedge Clk_i or negedge Reset_i)
	begin
		if(Reset_i == 1'b0)
			begin
				pwm_counter_r <= 4'd0;
			end
		else
			begin
				if(pwm_active_region_r == 1'b1)
					begin
						pwm_counter_r <= pwm_counter_r + 1'b1;
					end
				else
					begin
						pwm_counter_r <= 4'd0;
					end
			end
	end
	

always @ (*)
		begin
			if(Pwm_o == 1'b0 && pwm_delay_r == 1'b1 && pwm_counter_r < 4'd9)
				begin
					$display("Duty cycle is : %0d %%",((pwm_counter_r+1)*10));
			   end
			 if (pwm_active_region_r == 1'b1 && pwm_counter_r == 4'd9)
				begin
					$display("Duty cycle is : %0d %%",((pwm_counter_r+1)*10));
				end
		end
      
endmodule

