`timescale 1ns / 1ps
`include "give_your_local_location\paj7620_parameters.v"
//////////////////////////////////////////////////////////////////////////////////
// Company:        DIY Projects
// Engineer:       Sarmad Wahab 
// Create Date:    16:52:11 09/04/2021 
// Design Name:    Paj7620
// Module Name:    Uart_Transmission   
// Target Devices: Xilinx Spartan 6
// Tool versions:  Design ISE 14.7 
//////////////////////////////////////////////////////////////////////////////////
module Uart_Transmission(
	Clk_i,
	Reset_i,
	Data_Available_i,
	Data_i,
	Tx_o
    );

   input                                   Clk_i, Reset_i, Data_Available_i;
   input [uart_data_length_p - high_p : 0] Data_i;
   output 				   Tx_o;
   
   
   reg 					   tick_r;
   reg 					   start_tick_r;
   reg 					   tx_r;
   
   reg [uart_baud_rate_length_p       : 0] uart_tick_counter_r;
   reg [uart_data_frame_length_p      : 0] data_frame_r;
   reg [high_p                        : 0] next_state_r;
   reg [uart_frame_counter_p          : 0] uart_frame_counter_r;
   reg [uart_frame_counter_p-high_p   : 0] data_counter_r;
   
   reg [119                           : 0] gesture_data_r;
   reg 					   start_uart_r;
   
   always @ (posedge Clk_i or negedge Reset_i)  // Assign specific gestures
     begin
	if(Reset_i == low_p)
	  begin
	     data_frame_r <= {8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF};
	     start_uart_r <= low_p;
	  end
	else
	  begin
	     if(Data_Available_i == high_p)
	       begin
		  case(Data_i)
		    1:
		      begin
			 data_frame_r <= {cr_p,lf_p,104'h455349574B434F4C4349544E41};
		      end
		    2:
		      begin
			 data_frame_r <= {cr_p,lf_p,104'h455349574B434F4C43};
		      end
		    4:
		      begin
			 data_frame_r <= {cr_p,lf_p,104'h5055};
		      end
		    8:
		      begin
			 data_frame_r <= {cr_p,lf_p,104'h4E574F44};                     
		      end
		    16:
		      begin
			 data_frame_r <= {cr_p,lf_p,104'h5448474952}; 
		      end
		    32:
		      begin
			 data_frame_r <= {cr_p,lf_p,104'h5446454C}; 
		      end
		    64:
		      begin
			 data_frame_r <= {cr_p,lf_p,104'h445241574B434142};
		      end
		    128:
		      begin
			 data_frame_r <= {cr_p,lf_p,104'h44524157524F46};
		      end
		    default:
		      begin
			 data_frame_r <= zero_p;
		      end
		  endcase
		  start_uart_r <= high_p;
	       end
	     else
	       begin
		  data_frame_r <= data_frame_r;
		  start_uart_r <= low_p;
	       end
	  end
     end
   

   always @ (posedge Clk_i or negedge Reset_i) // This block is responsible to count 5208 clock cycles for 9600 baudrate 
     begin
	if(Reset_i == low_p)
	  begin
	     uart_tick_counter_r <= zero_p;
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
   
   always @ (posedge Clk_i or negedge Reset_i)  // FSM for Uart
     begin
	if(Reset_i == low_p)
	  begin
	     next_state_r                      <= fsm_uart_idle_p;
	     data_counter_r                    <= low_p;
             uart_frame_counter_r              <= {high_p,high_p,high_p,high_p,high_p};
	     start_tick_r                      <= low_p;
	     tx_r                              <= high_p;
	  end
	else
	  begin
	     case(next_state_r)
	       fsm_uart_idle_p:
		 begin
		    if(start_uart_r == high_p)
		      begin
			 next_state_r          <= fsm_uart_start_p;
			 start_tick_r          <= high_p;
			 tx_r                  <= low_p;
		      end
		    else
		      begin
			 next_state_r          <= fsm_uart_idle_p;
			 start_tick_r          <= low_p;
			 tx_r                  <= high_p;
		      end
		    data_counter_r             <= low_p;
		    uart_frame_counter_r       <= low_p;
		 end
	       fsm_uart_start_p:
		 begin
		    if(tick_r != high_p)
		      begin
			 next_state_r          <= next_state_r;
			 tx_r                  <= tx_r;
		      end
		    else
		      begin
			 next_state_r          <= fsm_uart_transmit_data_p;
			 tx_r                  <= data_frame_r[(uart_frame_counter_r * uart_data_length_p) + data_counter_r];
		      end
		    data_counter_r             <= data_counter_r;
		    uart_frame_counter_r       <= uart_frame_counter_r;
		    start_tick_r               <= start_tick_r;
		 end 
	       fsm_uart_transmit_data_p:
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
			 tx_r             <= data_frame_r[((uart_frame_counter_r * uart_data_length_p) + data_counter_r)];
			 data_counter_r   <= data_counter_r;
		      end
		    else
		      begin
			 next_state_r          <= fsm_uart_stop_p;
			 data_counter_r        <= low_p;
			 tx_r                  <= high_p;
		      end
		    uart_frame_counter_r       <= uart_frame_counter_r;
		    start_tick_r               <= start_tick_r;
		 end
	       fsm_uart_stop_p:
		 begin
		    if(tick_r == high_p && uart_frame_counter_r < uart_frames_p - single_bit_p)
		      begin
			 next_state_r          <= fsm_uart_start_p;
  			 uart_frame_counter_r  <= uart_frame_counter_r + single_bit_p;
			 start_tick_r          <= start_tick_r;
			 tx_r                  <= low_p;
		      end
		    else if (tick_r == high_p && uart_frame_counter_r == uart_frames_p - single_bit_p)
		      begin
			 next_state_r          <= fsm_uart_idle_p;
			 uart_frame_counter_r  <= low_p;
			 start_tick_r          <= low_p;
			 tx_r                  <= tx_r;
		      end
		    else
		      begin
			 next_state_r          <= next_state_r;
			 uart_frame_counter_r  <= uart_frame_counter_r;
			 start_tick_r          <= start_tick_r;
		      end
		    data_counter_r             <= data_counter_r;
		 end
	       default:
		 begin
		    next_state_r               <= fsm_uart_idle_p;
		    data_counter_r             <= low_p;
		    uart_frame_counter_r       <= low_p;
		    start_tick_r               <= low_p;
		    tx_r                       <= high_p;
		 end
	     endcase
	  end
     end
   
   assign Tx_o     = tx_r;
 
 
endmodule
