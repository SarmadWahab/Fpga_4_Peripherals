////////////////////////////////////////////////////////////////////////////////
// Company: DIY Projects
// Engineer: Sarmad Wahab
//
// Create Date: 11.07.2021
// Design Name: Ultrasonic sensor 
// Module Name: Data converter module (integer to ascii)
// Target Device: Xilinx Spartan 6
// Tool versions: Design ISE 14.7
////////////////////////////////////////////////////////////////////////////////
`include "give_your_local_location\hcsr04_parameters.v"

module ultrasonic_sensor_data_converter
  (
   Clk_i,
   Reset_i,
   Distance_i,
   Distance_Available_i,
   Distance_o,
   Distance_Available_o
   );

 
   input                                          Clk_i,Reset_i,Distance_Available_i;
   input  [div_ip_data_length_p              : 0] Distance_i;
   output [ultrasonic_sensor_data_length_p-1 : 0] Distance_o;
   output                                         Distance_Available_o;

   reg [fsm_state_length_p-1 		     : 0] next_state_r;
   reg [fsm_state_length_p+1 		     : 0] divide_ip_latency_counter_r;
   reg [single_bit_p         		     : 0] divide_stages_r;
   reg [ultrasonic_sensor_data_length_p-2    : 0] ascii_data_storage_r;
   reg                                            new_data_available_r;
   reg [ultrasonic_sensor_data_length_p-2    : 0] ascii_data_r;
   reg [div_ip_data_length_p       	     : 0] dividend_r;  
	
   wire [div_ip_data_length_p                : 0] quotient_w;   
   wire [numeber_of_division_stages          : 0] fractional_w;
   wire                                           rfd_w;
   
   
   always @ (posedge Clk_i or negedge Reset_i)  // This block is fsm that is used to convert integer to ascii value using mod by 10 technique !!!
     begin
	if(Reset_i == low_p)
	  begin
	     next_state_r                <= fsm_idle_p;
	     divide_ip_latency_counter_r <= low_p;
	     divide_stages_r             <= low_p;
	     ascii_data_storage_r        <= low_p;
	     new_data_available_r        <= low_p;
	     dividend_r                  <= low_p;
	  end
	else
	  begin
	     case(next_state_r)
	       fsm_idle_p:
		 begin
		    if(Distance_Available_i == high_p)
		      begin
			 next_state_r <= fsm_distance_in_cm_or_inches_p;
		      end
		    else
		      begin
			 next_state_r <= fsm_idle_p;
		      end
		    divide_ip_latency_counter_r <= low_p;
		    divide_stages_r             <= low_p;
		    ascii_data_storage_r        <= low_p;
		    new_data_available_r        <= low_p;
		    dividend_r                  <= low_p;
		 end
	       fsm_distance_in_cm_or_inches_p:
		 begin
		    if(divide_ip_latency_counter_r == divide_ip_latency_0)
		      begin
			 next_state_r                <= fsm_mod_data_p;
			 divide_ip_latency_counter_r <= low_p;
			 dividend_r                  <= Distance_i;
		      end
		    else
		      begin
			 next_state_r                <= next_state_r;
			 divide_ip_latency_counter_r <= divide_ip_latency_counter_r + single_bit_p;
			 dividend_r                  <= dividend_r;
		      end
		    divide_stages_r      <= divide_stages_r;
		    ascii_data_storage_r <= ascii_data_storage_r;
		    new_data_available_r <= new_data_available_r;
		 end
	       fsm_mod_data_p:
		 begin
		    if(divide_ip_latency_counter_r == divide_ip_latency_1)
		      begin
			 next_state_r                <= fsm_to_ascii_p;
			 divide_ip_latency_counter_r <= low_p;
		      end
		    else
		      begin
			 next_state_r                <= next_state_r;
			 divide_ip_latency_counter_r <= divide_ip_latency_counter_r + single_bit_p;
		      end
		    divide_stages_r      <= divide_stages_r;
		    ascii_data_storage_r <= ascii_data_storage_r;
		    new_data_available_r <= new_data_available_r;
		    dividend_r           <= dividend_r;
		 end
	       fsm_to_ascii_p:
		 begin
		    if(fsm_distance_in_cm_or_inches_p == single_bit_p)
		      begin
			 next_state_r                <= fsm_divide_data_p;
			 divide_ip_latency_counter_r <= low_p; 		
		      end
		    else
		      begin
			 next_state_r                <= next_state_r;
			 divide_ip_latency_counter_r <= divide_ip_latency_counter_r + single_bit_p;
		      end
		    divide_stages_r                       <= divide_stages_r;
		    ascii_data_storage_r                  <= {ascii_data_storage_r[div_ip_data_length_p-1:0],fractional_w};// Add remainder
		    new_data_available_r                  <= new_data_available_r;
		    dividend_r                            <= dividend_r;							     
		 end
	       fsm_divide_data_p:
		 begin
		    if(divide_ip_latency_counter_r == single_bit_p && divide_stages_r < numeber_of_division_stages - single_bit_p)
		      begin
			 next_state_r                <= fsm_mod_data_p;
			 divide_ip_latency_counter_r <= low_p;
			 divide_stages_r             <= divide_stages_r + single_bit_p;
			 new_data_available_r        <= new_data_available_r;
		      end
		    else if (divide_ip_latency_counter_r == single_bit_p && divide_stages_r == numeber_of_division_stages - single_bit_p)
		      begin
			 next_state_r                <= fsm_end_p;
			 divide_ip_latency_counter_r <= low_p;
			 divide_stages_r             <= low_p;
			 new_data_available_r        <= high_p;
		      end
		    else
		      begin
			 next_state_r                <= next_state_r;
			 divide_ip_latency_counter_r <= divide_ip_latency_counter_r + single_bit_p;
			 divide_stages_r             <= divide_stages_r;
			 new_data_available_r        <= new_data_available_r; 
		      end
		   ascii_data_storage_r <= ascii_data_storage_r;
		   dividend_r           <= quotient_w;
		 end
	       fsm_end_p:
		 begin
		    next_state_r                <= fsm_idle_p;
		    divide_ip_latency_counter_r <= low_p;
		    divide_stages_r             <= low_p;
		    new_data_available_r        <= low_p;
		    ascii_data_storage_r        <= low_p;
		    dividend_r                  <= low_p;
		 end
	       default:
		 begin
		    next_state_r                <= fsm_idle_p;
		    divide_ip_latency_counter_r <= low_p;
		    divide_stages_r             <= low_p;
		    new_data_available_r        <= low_p;
		    ascii_data_storage_r        <= low_p;
		    dividend_r                  <= low_p;
		 end
	     endcase
	  end
     end

   always @ (posedge Clk_i or negedge Reset_i)  // This block is used to update whenever new ascii value is available
     begin
	if(Reset_i == low_p)
	  begin
	     ascii_data_r <= low_p;
	  end
	else
	  begin
	     if(new_data_available_r == high_p)
	       begin
		  ascii_data_r <= ascii_data_storage_r;
	       end
	     else
	       begin
		  ascii_data_r <= ascii_data_r;
	       end
	  end
     end
 
	mod_ip mod (
	.clk(Clk_i), // input clk
	.rfd(rfd_w), // output rfd
	.dividend(dividend_r), // input [8 : 0] dividend
	.divisor(mod_by_10_p), // input [3 : 0] divisor
	.quotient(quotient_w), // output [8 : 0] quotient
	.fractional(fractional_w)); // output [3 : 0] fractional

   
   assign Distance_o           = {ascii_data_r,rfd_w};
   assign Distance_Available_o = new_data_available_r;
   



   
endmodule
