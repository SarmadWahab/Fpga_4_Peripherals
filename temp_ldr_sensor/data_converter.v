`include "give_your_local_location\Tmp_LDR_parameters.v"

////////////////////////////////////////////////////////////////////////////////
// Company:        DIY Projects 
// Engineer:       Sarmad Wahab 
// Create Date:    19:09:41 09/19/2021 
// Design Name:    Temperature & LDR sensor
// Module Name:    data_converter
// Target Devices: Xilinx Spartan 6
// Tool versions:  Design ISE 14.7
////////////////////////////////////////////////////////////////////////////////

module data_converter
  (
   Clk_i,
   Reset_i,
   Temp_LDR_i,
   Data_Available_i,
   Data_i,
   Data_Available_o,
   Data_o,
   Div_Stages_o,
   Unused_bits_o
);
   parameter data_length_p           =  4'hB;
   
   input                                Clk_i, Reset_i, Temp_LDR_i, Data_Available_i;
   input  [data_length_p           : 0] Data_i;
   output 		                Data_Available_o, Unused_bits_o;
   output [converted_data_length_p : 0] Data_o;
   output [high_p : 0] 			Div_Stages_o;

   reg 					data_available_r;
   
   reg [fsm_length_p                : 0] next_state_r;
   reg [spi_counter_length_p+high_p : 0] latency_counter_r;
   reg [dividend_length_p           : 0] dividend_r; 
   reg [data_length_p               : 0] multiply_by_500_r;     
   reg [converted_data_length_p     : 0] data_r;
   reg [divisor_length_p            : 0] divisor_r;
   reg [high_p                      : 0] div_stages_r;
   reg [converted_data_length_p     : 0] data_delay_r;
   
   wire 				 rfd_w;
   wire [dividend_length_p          : 0] quotient_w;         
   wire [divisor_length_p           : 0] fraction_w;
   wire [dividend_length_p          : 0] temp_value_r;  
	
   always @ (posedge Clk_i or negedge Reset_i)  // Delay data signal one clock cycle 
     begin
	if(Reset_i == low_p)
	  begin
	     data_delay_r <= zero_p;
	  end
	else
	  begin
	     if(next_state_r == fsm_stop_p)
	       begin
		  data_delay_r <= data_r;
	       end
	     else
	       begin
		  data_delay_r <= data_delay_r;
	       end
	  end
     end
	
   always @ (posedge Clk_i or negedge Reset_i)  // FSM for converting data to ASCII format
     begin
	if(Reset_i == low_p)
	  begin
	     next_state_r      <= fsm_idle_p;
	     latency_counter_r <= zero_p;
	     dividend_r        <= high_p;
	     multiply_by_500_r <= zero_p;
	     data_r            <= zero_p;
	     data_available_r  <= low_p;
	     divisor_r         <= {4'hF,4'hF,4'hF,high_p};
	     div_stages_r      <= zero_p;
	  end
	else
	  begin
	     case(next_state_r)
	       fsm_idle_p:
		 begin
		    if(Data_Available_i == high_p && Temp_LDR_i == high_p)
		      begin
			 div_stages_r      <= zero_p;
			 next_state_r      <= fsm_multiply_by_500_p;
			 multiply_by_500_r <= Data_i;
			 dividend_r        <= zero_p;
			 divisor_r         <= high_p;
		      end
		    else if (Data_Available_i == high_p && Temp_LDR_i == low_p)
		      begin
			 next_state_r      <= fsm_mod_10_p;
			 div_stages_r      <= zero_p;
			 multiply_by_500_r <= zero_p;
			 dividend_r        <= Data_i;
			 divisor_r         <= divisor_10_p;
		      end
		    else
		      begin
			 next_state_r      <=next_state_r;
			 dividend_r        <= zero_p;
			 divisor_r         <= high_p;
			 div_stages_r      <= div_stages_r;
			 multiply_by_500_r <= zero_p;
		      end
		    latency_counter_r <= zero_p;
		    data_r            <= zero_p;
		    data_available_r  <= low_p;		   
		 end
	       fsm_divide_by_1023_p:
		 begin
		    if(latency_counter_r == division_latency_p)
		      begin
			 next_state_r      <= fsm_mod_10_p;
			 latency_counter_r <= zero_p;
			 dividend_r        <= quotient_w;
			 divisor_r         <= divisor_10_p;
		      end
		    else
		      begin
			 next_state_r      <= next_state_r;
			 latency_counter_r <= latency_counter_r + high_p;
			 multiply_by_500_r <= multiply_by_500_r;
			 dividend_r        <= dividend_r;
			 divisor_r         <= divisor_r;
		      end
		    data_r           <= data_r;
		    data_available_r <= data_available_r;
		    div_stages_r     <= div_stages_r;
		 end
	       fsm_multiply_by_500_p:
		 begin
		    if(latency_counter_r == multiply_latency_p)
		      begin
			 next_state_r      <= fsm_divide_by_1023_p;
			 latency_counter_r <= zero_p;
			 dividend_r        <= temp_value_r;
			 divisor_r        <= divisor_1023_p;
		      end
		    else
		      begin
			 next_state_r      <= next_state_r;
			 latency_counter_r <= latency_counter_r + high_p;
			 dividend_r        <= dividend_r;
			 divisor_r         <= divisor_r;
		      end
		    multiply_by_500_r <= multiply_by_500_r;
		    data_available_r  <= data_available_r;
		    data_r            <= data_r;
		    div_stages_r      <= div_stages_r;
		 end
	       fsm_mod_10_p:
		 begin
		    if(latency_counter_r == division_latency_p && quotient_w == zero_p)
		      begin
			 next_state_r      <= fsm_stop_p;
			 dividend_r        <= dividend_r;
			 data_r            <= {data_r[11:0], fraction_w[3:0]};
			 latency_counter_r <= zero_p;
			 div_stages_r      <= div_stages_r;
		      end
		    else if (latency_counter_r == division_latency_p && quotient_w != zero_p)
		      begin
			 next_state_r      <= next_state_r;
			 dividend_r        <= quotient_w;
			 data_r            <= {data_r[11:0], fraction_w[3:0]};
			 latency_counter_r <= zero_p;
			 div_stages_r      <= div_stages_r + high_p;
		      end
		    else
		      begin
			 next_state_r      <= next_state_r;
			 dividend_r        <= dividend_r;
			 data_r            <= data_r;
			 latency_counter_r <= latency_counter_r + high_p;
			 div_stages_r      <= div_stages_r;
		      end
		    divisor_r         <= divisor_r;
		    multiply_by_500_r <= multiply_by_500_r;
		    data_available_r  <= data_available_r;
		 end
	       fsm_stop_p:
		 begin
		    next_state_r      <= fsm_idle_p;
		    latency_counter_r <= latency_counter_r;
		    dividend_r        <= dividend_r;
		    multiply_by_500_r <= multiply_by_500_r;
		    data_r            <= data_r;
		    data_available_r  <= high_p;
		    divisor_r         <= divisor_r;
		    div_stages_r      <= div_stages_r;
		 end
	       default:
		 begin
		    next_state_r      <= fsm_idle_p;
		    latency_counter_r <= zero_p;
		    dividend_r        <= zero_p;
		    multiply_by_500_r <= zero_p;
		    data_r            <= zero_p;
		    data_available_r  <= low_p;
		    divisor_r         <= high_p;
		 end
	     endcase
	  end
     end
 
   Divider_IP Div_IP (                           // Xilinx IP from core generator for division               
		      .clk(Clk_i), 
		      .rfd(rfd_w), 
		      .dividend(dividend_r), 
		      .divisor(divisor_r), 
		      .quotient(quotient_w), 
		      .fractional(fraction_w)); 

   Multiplier Mul_IP (                           // Xilin IP from core generator for multiplication
		      .clk(Clk_i), 
		      .a(multiply_by_500_r), 
		      .p(temp_value_r) 
);
	


   assign Data_Available_o = data_available_r;
   assign Data_o           = data_delay_r;
   assign Div_Stages_o     = div_stages_r;
   assign Unused_bits_o    = rfd_w;
   
  
endmodule
