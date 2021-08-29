`timescale 1ns / 1ps
`include "give_your_local_location\adxl345_parameters.v"
//////////////////////////////////////////////////////////////////////////////////
// Company:        DIY Projects 
// Engineer:       Sarmad Wahab 
// Create Date:    21:49:17 08/26/2021 
// Design Name:    Adxl345 sensor 
// Module Name:    adxl345_data_converter  
// Target Devices: Xilinx Spartan 6 
// Tool versions:  ISE Design 14.7 
//////////////////////////////////////////////////////////////////////////////////
module adxl345_data_converter(
   Clk_i,
   Reset_i,
   Data_Available_i,
   X_i,
   Y_i,
   Z_i,
   Data_Available_o,
   Data_o,
   Unused_bits_o
   );
   
   parameter fsm_idle_p          	        = 3'd0;


   input                                          Clk_i,Reset_i,Data_Available_i;
   input signed [offset_p                    : 0] X_i;
   input signed [offset_p                    : 0] Y_i;
   input signed [offset_p                    : 0] Z_i;
   output                                         Data_Available_o, Unused_bits_o;
   output [characteristics_mantissa_length_p : 0] Data_o;
   
   reg                                            data_available_r;
   reg                                            stages_for_mod_is_done_r;

   reg [data_converter_internal_counter_p    : 0] i2c_internal_counter_r;
   reg [eight_clock_cycles_p                 : 0] characteristics_for_all_axes_r;
   reg [mantissa_length_p                    : 0] mantissa_for_all_axes_r;
   reg [high_p                               : 0] axes_number_r;
   reg [i2c_fsm_state_length_p               : 0] next_state_r;
   reg signed [offset_p                      : 0] data_r;
   reg signed [offset_p                      : 0] quotient_0_r;
   reg [eight_clock_cycles_p-high_p          : 0] fraction_0_r;
	
   wire signed [offset_p                     : 0] quotient_0_w;
   wire [eight_clock_cycles_p-high_p         : 0] fraction_0_w;
   wire [offset_p                            : 0] quotient_from_mod_w;
   wire signed [offset_p                     : 0] remainder_w;
  

   always @ (posedge Clk_i or negedge Reset_i)  // This block is responsible to set x value for ascii conversion 
     begin
	if(Reset_i == low_p)
	  begin
	     data_r <= low_p;
	     
	  end
	else
	  begin
	     case(axes_number_r)
	       0:
		 begin
		    data_r <= X_i;  
		 end
	       1:
		 begin
		    data_r <= Y_i;
		 end
	       2:
		 begin
		    data_r <= Z_i;
		 end
	       default:
		 begin
		    data_r <= low_p;
		 end
	     endcase
	  end
     end


   always @ (posedge Clk_i or negedge Reset_i)  // This FSM is responsible for covnersion of axes values to ASCII values 
     begin
	if(Reset_i == low_p)
	  begin
	     next_state_r                   <= fsm_idle_p;
	     axes_number_r                  <= low_p;
	     quotient_0_r                   <= low_p;
	     fraction_0_r                   <= low_p;
	     characteristics_for_all_axes_r <= low_p;
	     i2c_internal_counter_r         <= low_p;
	     stages_for_mod_is_done_r       <= low_p;
	     mantissa_for_all_axes_r        <= low_p;
	     data_available_r               <= low_p;
	  end
	else
	  begin
	     case(next_state_r)
	       fsm_idle_p:
		 begin
		    if(Data_Available_i == high_p)
		      begin
			 next_state_r <= fsm_start_p;
		      end
		    else
		      begin
			 next_state_r <= fsm_idle_p;
		      end
		    axes_number_r                  <= low_p;
		    quotient_0_r                   <= low_p;
		    fraction_0_r                   <= low_p;
		    characteristics_for_all_axes_r <= low_p;
		    i2c_internal_counter_r         <= low_p;
		    stages_for_mod_is_done_r       <= low_p;
		    mantissa_for_all_axes_r        <= low_p;
		    data_available_r               <= low_p;
		 end
	       fsm_start_p :
		 begin
		    if(i2c_internal_counter_r == divider_latency_0_p)
		      begin
			 next_state_r  <= fsm_ch_mod_p;
			 quotient_0_r  <= quotient_0_w; 
			 fraction_0_r  <= fraction_0_w;
			 i2c_internal_counter_r <= low_p;
			 
		      end
		    else
		      begin
			 next_state_r <= next_state_r;
			 quotient_0_r <= quotient_0_r;
			 fraction_0_r <= fraction_0_r;
			 i2c_internal_counter_r <= i2c_internal_counter_r + single_bit_p;
		      end
		    axes_number_r                  <= axes_number_r;
		    characteristics_for_all_axes_r <= characteristics_for_all_axes_r;
		    stages_for_mod_is_done_r <= stages_for_mod_is_done_r;
		    mantissa_for_all_axes_r <= mantissa_for_all_axes_r;
		    data_available_r  <= data_available_r;
		 end
	       fsm_ch_mod_p :
		 begin
		    if(i2c_internal_counter_r == divider_latency_1_p)
		      begin
			 next_state_r                   <= fsm_mantissa_mod_p;
			 characteristics_for_all_axes_r <= {remainder_w[2:0],characteristics_for_all_axes_r[8:3]};
			 quotient_0_r                   <= (fraction_0_r * multiply_by_1000_p) >> right_shift_p;
			 i2c_internal_counter_r <= low_p;
		      end
		    else
		      begin
			 next_state_r                   <= next_state_r;
			 characteristics_for_all_axes_r <= characteristics_for_all_axes_r;
			 i2c_internal_counter_r <= i2c_internal_counter_r + single_bit_p;
			 quotient_0_r <= quotient_0_r;
		      end
		    fraction_0_r  <= fraction_0_r;
		    axes_number_r <= axes_number_r;
		    stages_for_mod_is_done_r <= stages_for_mod_is_done_r;
		    mantissa_for_all_axes_r <= mantissa_for_all_axes_r;
		    data_available_r  <= data_available_r;
		 end
	       fsm_mantissa_mod_p:
		 begin
		    if(i2c_internal_counter_r == divider_latency_1_p && stages_for_mod_is_done_r == high_p)
		      begin
			 next_state_r             <= fsm_end_p;
			 i2c_internal_counter_r   <= low_p;
			 stages_for_mod_is_done_r <= low_p;
			 quotient_0_r               <= quotient_0_r;
			 mantissa_for_all_axes_r  <= {remainder_w[3:0],mantissa_for_all_axes_r[23:4]};
			 axes_number_r           <= axes_number_r + single_bit_p;
		      end
		    else if (i2c_internal_counter_r == divider_latency_1_p && stages_for_mod_is_done_r != high_p)
		      begin
			 next_state_r             <= next_state_r;
			 i2c_internal_counter_r   <= low_p;
			 stages_for_mod_is_done_r <= high_p;
			 quotient_0_r             <= quotient_from_mod_w;
			 mantissa_for_all_axes_r  <= {remainder_w[3:0],mantissa_for_all_axes_r[23:4]};
			 axes_number_r           <= axes_number_r;
		      end
		    else
		      begin
			 next_state_r             <= next_state_r;
			 i2c_internal_counter_r   <= i2c_internal_counter_r + single_bit_p;
			 stages_for_mod_is_done_r <= stages_for_mod_is_done_r;
			 quotient_0_r               <= quotient_0_r;
			 mantissa_for_all_axes_r  <= mantissa_for_all_axes_r;
			 axes_number_r           <= axes_number_r;
		      end 
		    fraction_0_r                   <= fraction_0_r;
		    characteristics_for_all_axes_r <= characteristics_for_all_axes_r;
		    data_available_r               <= data_available_r;
		 end
	       fsm_end_p :
		 begin
		    if(axes_number_r == total_number_of_axes)
		      begin
			 next_state_r 		 <= fsm_idle_p;
			 data_available_r        <= high_p;
		      end
		    else
		      begin
			 next_state_r            <= fsm_start_p;
			 data_available_r        <= low_p;
		      end
		    i2c_internal_counter_r         <= low_p;
		    characteristics_for_all_axes_r <= characteristics_for_all_axes_r;
		    mantissa_for_all_axes_r        <= mantissa_for_all_axes_r;
		    stages_for_mod_is_done_r       <= stages_for_mod_is_done_r;
		    quotient_0_r                     <= quotient_0_r;
		    fraction_0_r                   <= fraction_0_r;
		    axes_number_r                  <= axes_number_r;
		 end
	     endcase
	  end
     end

    div_ip divide_by_resolution (     // Divier IP used from Xilin Core Generator
	.clk(Clk_i),                  // input clk
	.rfd(rfd_0_w),                // output rfd
	.dividend(data_r),            // input [15 : 0] dividend
	.divisor(accel_resolution_p), // input [8 : 0] divisor
	.quotient(quotient_0_w),      // output [15 : 0] quotient
	.fractional(fraction_0_w));
	
    div_ip_by_10 mod_by_10 (            // Divier IP used from Xilin Core Generator
	.clk(Clk_i),                    // input clk
	.rfd(rfd_1_w),                  // output rfd
	.dividend(quotient_0_r),        // input [15 : 0] dividend
	.divisor(mod_by_10_p),          // input [15 : 0] divisor
	.quotient(quotient_from_mod_w), // output [15 : 0] quotient
	.fractional(remainder_w));	

   assign Data_Available_o = data_available_r;
   assign Data_o = {characteristics_for_all_axes_r,mantissa_for_all_axes_r};
   assign Unused_bits_o = rfd_0_w & rfd_1_w;

endmodule
