////////////////////////////////////////////////////////////////////////////////
// Company: DIY Projects
// Engineer: Sarmad Wahab
//
// Create Date: 11.07.2021
// Design Name: Ultrasonic sensor 
// Module Name: Echo module
// Target Device: Xilinx Spartan 6
// Tool versions: Design ISE 14.7
////////////////////////////////////////////////////////////////////////////////
`include "give_your_local_location\hcsr04_parameters.v"

module ultrasonic_sensor_echo
  (
   Clk_i,
   Reset_i,
   Echo_i,
   cm_or_inches_i,
   Distance_o,
   Data_available_o
);
  
   
   input                                    Clk_i,Reset_i,Echo_i,cm_or_inches_i;
   output [distance_length_p : 0]           Distance_o;
   output                                   Data_available_o;

   reg 				            delay_echo_r;
   reg                                      active_echo_region_r;
   reg [echo_duty_cycle_counter_r-1  : 0]   echo_counter_r;
   reg                                      new_distance_available_r;
   reg [echo_duty_cycle_counter_r-4  : 0]   distance_in_cm_or_inches_r;
   reg [echo_duty_cycle_counter_r+3  : 0]   dividend_r;
  
   wire [echo_duty_cycle_counter_r+3 : 0]   quotient_w;
   wire [echo_duty_cycle_counter_r-4 : 0]   fraction_w;
   wire                                     rfd_w;
   


  always @ (*)  // This modules selects whether to present output in cm or inches 
    begin
       if(Reset_i == low_p)
	 begin
	    distance_in_cm_or_inches_r <= low_p;
	 end
       else
	 begin
	    case (cm_or_inches_i)
	      low_p:
		begin
		   distance_in_cm_or_inches_r <= in_cm_p;
		end
	      high_p:
		begin
		   distance_in_cm_or_inches_r <= in_inches_p;
		end
	      default:
		begin
		   distance_in_cm_or_inches_r <= all_bits_one_p;
		end
	    endcase
	 end
   end 


  
   
   always @ (posedge Clk_i or negedge Reset_i)  // This block delay echo signal by one clock cycle
     begin
	if(Reset_i == low_p)
	  begin
	     delay_echo_r <= low_p;
	  end
	else
	  begin
	     delay_echo_r <= Echo_i;
	  end
     end 


   always @ (posedge Clk_i or negedge Reset_i)   // This block calculates the rise and fall edge for echo signal
     begin
	if(Reset_i == low_p)
	  begin
	     active_echo_region_r     <= low_p;
	     new_distance_available_r <= low_p;
	  end
	else
	  begin
	     if(Echo_i == high_p && delay_echo_r == low_p)
	       begin
		  active_echo_region_r     <= high_p;
		  new_distance_available_r <= low_p;
	       end
	     else if (Echo_i == low_p && delay_echo_r == high_p)
	       begin
		  active_echo_region_r     <= low_p;
		  new_distance_available_r <= high_p;
	       end
	     else
	       begin
		  active_echo_region_r     <= active_echo_region_r;
		  new_distance_available_r <= low_p;
	       end
	  end
     end 


   always @ (posedge Clk_i or negedge Reset_i)  // This block calculates the duty cycle for echo signal
     begin
	if(Reset_i == low_p)
	  begin
	     echo_counter_r <= low_p;
	  end
	else
	  begin
	     if(active_echo_region_r == high_p)
	       begin
		  echo_counter_r <= echo_counter_r + single_bit_p;
	       end
	     else
	       begin
		  echo_counter_r <= low_p;
	       end
	  end
     end 


   always @ (posedge Clk_i or negedge Reset_i)  // This block assign correct value to dividend (in nano seconds)
     begin
	if(Reset_i == low_p)
	  begin
	     dividend_r <= {single_bit_p,all_bits_one_p,all_bits_one_p,all_bits_one_p};
	  end
	else
	  begin
	     if(new_distance_available_r == high_p)
	       begin
		    dividend_r <= (echo_counter_r << multiply_by_4_p) * to_nanoseconds_p;
	       end
	     else
	       begin
		    dividend_r <= dividend_r;
	       end
	  end
     end

 
   
	divide_IP div_ip (
	.clk(Clk_i), // input clk
	.rfd(rfd_w), // output rfd
	.dividend(dividend_r), // input [24 : 0] dividend
	.divisor(distance_in_cm_or_inches_r), // input [17 : 0] divisor
	.quotient(quotient_w), // output [24 : 0] quotient
	.fractional(fraction_w)); // output [17 : 0] fractional

   assign Distance_o       = {rfd_w,fraction_w,quotient_w};
   assign Data_available_o = new_distance_available_r;
   
   
   
  
 endmodule
	
