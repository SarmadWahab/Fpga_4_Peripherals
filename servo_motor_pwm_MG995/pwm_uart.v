////////////////////////////////////////////////////////////////////////////////
// Company: DIY Projects
// Engineer: Sarmad Wahab
//
// Create Date: 25.06.2021
// Design Name: PWM generation for DC Servo Motor MG995
// Module Name: pwm_uart
// Target Device: Xilinx Spartan 6
// Tool versions: Design ISE 14.7
////////////////////////////////////////////////////////////////////////////////

`include "give_your_local_location\mg995_parameters.v"

module pwm_uart
   (Clk_i,
    Reset_i,
    Enable_i,
    Data_i,
    Tx_o
);

 

   input                       Clk_i, Reset_i, Enable_i;
   input  [data_length_p-1 :0] Data_i;
   output 		       Tx_o;

   reg [uart_max_frame_p-1  :0]      data_to_transmit_r;
   reg [size_p              :0]      uart_iteration_r;
   reg [size_p-1            :0]      next_state_r; 
   reg [size_p              :0]      uart_frame_counter_r;
   reg [data_length_p-5     :0]      uart_tick_counter_r;
   reg                               tick_r;
   reg                               tx_r;
   reg                               start_tick_r;
   reg [uart_data_length_p-5  :0]    data_counter_r;
   reg [data_length_p-1       :0]    data_input_r;
 

 
   always @ (posedge Clk_i or negedge Reset_i)  // This block is responsible to set the pwm configuration for uart serial port
	 begin
	    if(Reset_i == low_p)
	      begin
		 data_to_transmit_r <= low_p;
		 uart_iteration_r   <= low_p;
	      end
	    else
	      begin
		 case(Data_i)
		   24999:
		     begin
			data_to_transmit_r <= angle_0_hex_code_p;
                        uart_iteration_r   <= size_p;
		     end
		   74999:
		     begin
			data_to_transmit_r <= angle_90_hex_code_p;
			uart_iteration_r   <= size_p + single_bit_p;
		     end
		   124999:
		     begin
			data_to_transmit_r <= angle_180_hex_code_p;
                        uart_iteration_r   <= size_p + size_p;
								
		     end
		   default:
		     begin
			data_to_transmit_r <= all_bits_one_p;
			uart_iteration_r   <= low_p;
		     end
		 endcase
	      end
	 end


   always @ (posedge Clk_i or negedge Reset_i)  // FSM for Uart
     begin
	if(Reset_i == low_p)
	  begin
	     next_state_r                      <= idle_p;
	     data_counter_r                    <= low_p;
        uart_frame_counter_r                   <= low_p;
	     start_tick_r                      <= low_p;
	     tx_r                              <= high_p;
	     data_input_r                      <= low_p;
	  end
	else
	  begin
	     case(next_state_r)
	       idle_p:
		 begin
		    if(Enable_i == high_p && data_input_r != Data_i && uart_iteration_r != low_p)
		      begin
			 next_state_r          <= start_p;
			 start_tick_r          <= high_p;
			 tx_r                  <= low_p;
		      end
		    else
		      begin
			 next_state_r          <= idle_p;
			 start_tick_r          <= low_p;
			 tx_r                  <= high_p;
		      end
		    data_counter_r             <= low_p;
          uart_frame_counter_r       <= low_p;
		    data_input_r               <= data_input_r;
		 end
	       start_p:
		 begin
		    if(tick_r != high_p)
		      begin
			 next_state_r          <= next_state_r;
			 tx_r                  <= tx_r;
		      end
		    else
		      begin
			 next_state_r          <= transmit_data_p;
			 tx_r                  <= data_to_transmit_r[uart_max_frame_p - single_bit_p];
		      end
                    data_counter_r             <= data_counter_r;
                    uart_frame_counter_r       <= uart_frame_counter_r;
		    start_tick_r               <= start_tick_r;
		    data_input_r               <= data_input_r;
		 end
	       transmit_data_p:
		 begin
		    if(tick_r == high_p && data_counter_r < (uart_data_length_p))
		      begin
			 next_state_r          <= next_state_r;
			 data_counter_r        <= data_counter_r + single_bit_p;
			 tx_r                  <= tx_r;
		      end
		    else if (tick_r == low_p && data_counter_r < (uart_data_length_p))
		      begin
			 next_state_r     <= next_state_r;
			 tx_r             <= data_to_transmit_r[(uart_max_frame_p - single_bit_p) - ((uart_frame_counter_r * uart_data_length_p) + data_counter_r)];
			 data_counter_r   <= data_counter_r;
		      end
		    else
		      begin
			 next_state_r          <= stop_p;
			 data_counter_r        <= low_p;
			 tx_r                  <= high_p;
		      end
		    uart_frame_counter_r       <= uart_frame_counter_r;
		    start_tick_r               <= start_tick_r;
		    data_input_r               <= data_input_r;
		 end
	       stop_p:
		 begin
		    if(tick_r == high_p && uart_frame_counter_r < uart_iteration_r)
		      begin
			 next_state_r          <= start_p;
  			 uart_frame_counter_r  <= uart_frame_counter_r + single_bit_p;
			 start_tick_r          <= start_tick_r;
			 tx_r                  <= low_p;
			 data_input_r          <= data_input_r;
		      end
		    else if (tick_r == high_p && uart_frame_counter_r == uart_iteration_r)
		      begin
			 next_state_r          <= idle_p;
			 uart_frame_counter_r  <= low_p;
			 start_tick_r          <= low_p;
			 tx_r                  <= tx_r;
			 data_input_r          <= Data_i;
		      end
		    else
		      begin
			 next_state_r          <= next_state_r;
			 uart_frame_counter_r  <= uart_frame_counter_r;
			 start_tick_r          <= start_tick_r;
			 data_input_r          <= data_input_r;
		      end
		    data_counter_r             <= data_counter_r;
		 end
	       default:
		 begin
		    next_state_r               <= idle_p;
		    data_counter_r             <= low_p;
		    uart_frame_counter_r       <= low_p;
		    start_tick_r               <= low_p;
		    tx_r                       <= high_p;
		    data_input_r               <= low_p;
		 end
	     endcase
	  end
     end


   always @ (posedge Clk_i or negedge Reset_i) // This block is responsible to count 5208 clock cycles for 9600 baudrate 
     begin
	if(Reset_i == low_p)
	  begin
	     uart_tick_counter_r <= low_p;
	  end
	else
	  begin
	     if(start_tick_r == high_p && uart_tick_counter_r < baud_rate_p)
	       begin
		  uart_tick_counter_r <= uart_tick_counter_r + single_bit_p;
	       end
	     else
	       begin
		  uart_tick_counter_r <= low_p;
	       end
	  end
     end

   always @ (posedge Clk_i or negedge Reset_i) // This block flags signal whenever counter has counted 5208 clock cycles
     begin
	if(Reset_i == low_p)
	  begin
	     tick_r <= low_p;
      	  end
	else
	  begin
	     if(uart_tick_counter_r == baud_rate_p)
	       begin
		  tick_r <= high_p;
	       end
	     else
	       begin
		  tick_r <= low_p;
	       end
	  end
     end

   assign Tx_o = tx_r;
	
   
   
endmodule
