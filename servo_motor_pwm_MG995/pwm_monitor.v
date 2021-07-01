////////////////////////////////////////////////////////////////////////////////
// Company: DIY Projects
// Engineer: Sarmad Wahab
//
// Create Date: 25.06.2021
// Design Name: PWM generation for DC Servo Motor MG995
// Module Name: pwm_monitor
// Target Device: Xilinx Spartan 6
// Tool versions: Design ISE 14.7
////////////////////////////////////////////////////////////////////////////////
`include "give_your_local_location\mg995_parameters.v"

module pwm_monitor
  (
   Clk_i,
   Reset_i,
   Pwm_i,
   Sel_i,
   Duty_Cycle_o,
   Available_o
);


   input  Clk_i, Reset_i, Pwm_i;
   input  [mux_sel_length_p-1 :0]             Sel_i;
   output [duty_cycle_counter_length_p-1 : 0] Duty_Cycle_o;
   output 				      Available_o;
   
 
   reg [duty_cycle_counter_length_p-1 : 0] duty_cycle_size_r;
   reg [duty_cycle_counter_length_p-1 : 0] duty_cycle_r;
   reg [duty_cycle_counter_length_p-1 : 0] duty_cycle_counter_r;

   reg pwm_active_region_r;
   reg delay_pwm_r;
   reg available_r;
   
     
   

   always @ (posedge Clk_i or negedge Reset_i)  // This block is responsible for pwm configuration
     begin
	if(Reset_i == low_p)
	  begin
	     duty_cycle_size_r<= low_p; 
	  end
	else
	  begin
	     case(Sel_i)
	       0:
		 begin
		    duty_cycle_size_r<= all_bits_one_p;
		 end
	       1:
		 begin
		    duty_cycle_size_r<= angle_0_clock_cycles_p;
		 end
	       2:
		 begin
		    duty_cycle_size_r<= angle_90_clock_cycles_p;
		 end
	       3:
		 begin
		    duty_cycle_size_r<= angle_180_clock_cycles_p; 
		 end
	       default:
		 begin
		    duty_cycle_size_r<= low_p;
		 end
	     endcase
	     
	  end
     end


   always @ (posedge Clk_i or negedge Reset_i)  // One clock cycle delay of pwn signal
     begin
	if(Reset_i == low_p)
	  begin
	     delay_pwm_r <= low_p;
	  end
	else
	  begin
	     delay_pwm_r <= Pwm_i;
	  end
     end

  
 
   always @ (posedge Clk_i or negedge Reset_i) // This block is responsible to detect the rise edge and fall edge of pwm signal
     begin
	if(Reset_i == low_p)
	  begin
	     pwm_active_region_r <= low_p;
	  end
	else
	  begin
	     if(Pwm_i == high_p && delay_pwm_r == low_p)
	       begin
		  pwm_active_region_r <= high_p;
	       end
	     else if (Pwm_i == low_p && delay_pwm_r == high_p)
	       begin
		  pwm_active_region_r <= low_p;
	       end
	     else
	       begin
		  pwm_active_region_r <= pwm_active_region_r;
	       end
	  end
     end

  
   
   always @ (posedge Clk_i or negedge Reset_i)  // This block is responsible to calculate the length of duty cycle
     begin
	if(Reset_i == low_p)
	  begin
	     duty_cycle_counter_r <= low_p;
	  end
	else
	  begin
	     if(pwm_active_region_r == high_p && duty_cycle_counter_r < duty_cycle_size_r)
	       begin
		  duty_cycle_counter_r <= duty_cycle_counter_r + single_bit_p;
	       end
	     else
	       begin
		  duty_cycle_counter_r <= low_p; 
	       end
	  end
     end

   always @ (posedge Clk_i or negedge Reset_i) // This block is responsible to represent whenever new duty cycle is generated 
     begin
	if(Reset_i == low_p)
	  begin
	     available_r  <= low_p;
	     duty_cycle_r <= some_bits_one_p; 
	  end
	else
	  begin
	     if(Pwm_i == low_p && delay_pwm_r == high_p && Sel_i != low_p &&  ((duty_cycle_counter_r == angle_0_clock_cycles_p - single_bit_p) || (duty_cycle_counter_r == angle_90_clock_cycles_p - single_bit_p) || (duty_cycle_counter_r == angle_180_clock_cycles_p - single_bit_p)))
	       begin
		  available_r   <= high_p;
		  duty_cycle_r <= duty_cycle_counter_r;
	       end
	     else
	       begin
		  available_r   <= low_p;
		  duty_cycle_r <= duty_cycle_r;
	       end
	  end
     end

   assign Duty_Cycle_o = duty_cycle_r;
   assign Available_o  = available_r;

endmodule

   
