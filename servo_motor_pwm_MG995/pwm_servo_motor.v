////////////////////////////////////////////////////////////////////////////////
// Company: DIY Projects
// Engineer: Sarmad Wahab
//
// Create Date: 25.06.2021
// Design Name: PWM generation for DC Servo Motor MG995
// Module Name: pwm_servo_motor
// Target Device: Xilinx Spartan 6
// Tool versions: Design ISE 14.7
////////////////////////////////////////////////////////////////////////////////
`include "give_your_local_location\mg995_parameters.v"

module pwm_servo_motor
   (
    Clk_i,
    Reset_i,
    Sel_angle_i,
    Pwm_o
);

   
   input  Clk_i, Reset_i;
   input  [mux_sel_length_p-1:0] Sel_angle_i;
   output Pwm_o;
				       
   
   reg input_is_stable_r;
   reg pwm_r;

   reg [stable_clock_cycles_p-5 : 0]  stable_clock_cycles_count_r;
   reg [pwm_counter_length_p-1  : 0]  pwm_counter_r;
   reg [pwm_counter_length_p-4  : 0]  angle_clock_cycles_r;
   reg [mux_sel_length_p-1      : 0]  sel_r;
  
   
     
  
   always @ (posedge Clk_i or negedge Reset_i)  // This block is responsible to select the correct pwm configuration
     begin
	if(Reset_i == low_p)
	  begin
	     angle_clock_cycles_r <= low_p;
	     sel_r                <= low_p;
	  end
	else
	  begin
	     case(Sel_angle_i)
	       0:
		 begin
		    angle_clock_cycles_r <= all_bits_one_p;
		    sel_r                <= low_p;
		 end
	       1:
		 begin
		    angle_clock_cycles_r <= angle_0_clock_cycles_p;
		    sel_r                <= Sel_angle_i;
		 end
	       2:
		 begin
		    angle_clock_cycles_r <= angle_90_clock_cycles_p;
		    sel_r                <= Sel_angle_i;
		 end
	       3:
		 begin
		    angle_clock_cycles_r <= angle_180_clock_cycles_p;
		    sel_r                <= Sel_angle_i;
		 end
	       default:
		 begin
		    angle_clock_cycles_r <= low_p;
		    sel_r                <= low_p;
		 end
	     endcase	     
	  end      
     end

  
  
   always @ (posedge Clk_i or negedge Reset_i) // This block is responsible to make sure input is stable (no glitches) for desired clock cycles 
     begin
	if(Reset_i == low_p)
	  begin
	     stable_clock_cycles_count_r <= low_p;
	  end
	else
	  begin
	     if(stable_clock_cycles_count_r < stable_clock_cycles_p && sel_r == Sel_angle_i && Sel_angle_i != low_p) // Counter will be incremented only when signal is valid position
	       begin
		  stable_clock_cycles_count_r <= stable_clock_cycles_count_r + single_bit_p;
	       end
	     else if (stable_clock_cycles_count_r == stable_clock_cycles_p && sel_r == Sel_angle_i && Sel_angle_i != low_p)
	       begin
		  stable_clock_cycles_count_r <= stable_clock_cycles_count_r;
	       end
	     else
	       begin
		  stable_clock_cycles_count_r <= low_p;  
	       end
	  end	
     end // always @ (posedge Clk_i)
   

   always @ (posedge Clk_i or negedge Reset_i) //input is stable for desired clock cycles
     begin
	if(Reset_i == low_p)
	  begin
	     input_is_stable_r <= low_p;
	  end
	else
	  begin
	     if(stable_clock_cycles_count_r == stable_clock_cycles_p)
	       begin
		  input_is_stable_r <= high_p;
	       end
	     else
	       begin
		  input_is_stable_r <= low_p;
	       end
	  end
     end

   always @ (posedge Clk_i or negedge Reset_i) // Input is stable, pwm_counter will start counting
     begin
	if(Reset_i == low_p)
	  begin
	     pwm_counter_r <= low_p;
	  end
	else
	  begin
	     if(input_is_stable_r == high_p && pwm_counter_r < pwm_clock_cycles_p)
	       begin
		  pwm_counter_r <= pwm_counter_r + single_bit_p;
	       end
	     else
	       begin
		  pwm_counter_r <= low_p;
	       end
	  end
     end

   always @ (posedge Clk_i or negedge Reset_i) // Generating 0,90,180 or 0.5ms, 1.5ms & 2.5ms pwm signal
     begin
	if(Reset_i == low_p)
	  begin
	     pwm_r <= low_p;	     
	  end
	else
	  begin
	     if(pwm_counter_r < angle_clock_cycles_r && input_is_stable_r == high_p && Sel_angle_i != low_p)
	       begin
		  pwm_r <= high_p;
	       end
	     else
	       begin
		  pwm_r <= low_p;
	       end
	  end
     end
   
assign Pwm_o        = pwm_r;
   
endmodule
