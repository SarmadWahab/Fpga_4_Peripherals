////////////////////////////////////////////////////////////////////////////////
// Company: DIY Projects
// Engineer: Sarmad Wahab
//
// Create Date: 01.07.2021
// Design Name: PWM generation for DC Motor MG33
// Module Name: pwm_dc_motor
// Target Device: Xilinx Spartan 6
// Tool versions: Design ISE 14.7
////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps
`include "give_your_local_location\mg33_parameters.v"

module pwm_dc_motor 
  (
   Clk_i,
   Reset_i,
   Sel_i,
   Pwm_o
);

   
   input                              Clk_i, Reset_i;
   input [mux_selector_length_p-1 :0] Sel_i;
   output 			      Pwm_o;

   reg [pwm_counter_length_p-1 :0]    pwm_duty_cycle_r;
   reg [pwm_counter_length_p-1 :0]    pwm_counter_r;
   reg                                pwm_r;
   

   
  always @ (posedge Clk_i or negedge Reset_i)  // This block is responsible for selection of duty cycle configuration
     begin
	if(Reset_i == low_p)
	  begin
	     pwm_duty_cycle_r <= low_p;
	  end
	else
	  begin
	     case(Sel_i)
	       0:
		 begin
		    pwm_duty_cycle_r <= all_bits_one_p;
		 end
	       1:
		 begin
		    pwm_duty_cycle_r <= pwm_14_duty_cycle_p;
		 end
	       2:
		 begin
		    pwm_duty_cycle_r <= pwm_25_duty_cycle_p; 
		 end
	       3:
		 begin
		    pwm_duty_cycle_r <= pwm_100_duty_cycle_p; 
		 end
	       default:
		 begin
		    pwm_duty_cycle_r <= low_p;
		 end
	     endcase
	  end
  end
	 
   always @ (posedge Clk_i or negedge Reset_i)  // Pwm counter start counting whenever valid configuration is switched 
     begin
	if(Reset_i == low_p)
	  begin
	     pwm_counter_r <= low_p;
	  end
	else
	  begin
	     if(Sel_i != low_p && pwm_counter_r < pwm_counter_limit_p - single_bit_p)
	       begin
		     pwm_counter_r <= pwm_counter_r + single_bit_p;
	       end
	     else
	       begin
		    pwm_counter_r <= low_p;
	       end
	  end
     end 
   

    always @ (posedge Clk_i or negedge Reset_i)  // Generation of pwm signal with variable duty cycle 
      begin
	 if(Reset_i == low_p)
	   begin
	      pwm_r <= low_p;
	   end
	 else
	   begin
	      if(pwm_counter_r < pwm_duty_cycle_r && Sel_i != low_p)
		begin
		   pwm_r <= high_p;
		end
	      else
		begin
		   pwm_r <= low_p;
		end
	   end
      end

   assign Pwm_o = pwm_r;   

endmodule
