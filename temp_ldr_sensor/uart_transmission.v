`include "give_your_local_location\Tmp_LDR_parameters.v"

////////////////////////////////////////////////////////////////////////////////
// Company:        DIY Projects 
// Engineer:       Sarmad Wahab 
// Create Date:    19:09:41 09/19/2021 
// Design Name:    Temperature & LDR sensor
// Module Name:    uart_transmission
// Target Devices: Xilinx Spartan 6
// Tool versions:  Design ISE 14.7
////////////////////////////////////////////////////////////////////////////////

module uart_transmission
  (
   Clk_i,
   Reset_i,
   Data_available_i,
   Data_i,
   Temp_LDR_i,
   Div_Stages_i,
   Tx_o
  );
   
   parameter data_length_p               = 4'hF;

   
   input Clk_i, Reset_i, Data_available_i, Temp_LDR_i;
   input [data_length_p : 0] Data_i;
   input [high_p        : 0] Div_Stages_i;
   output 		     Tx_o;
   
   reg [uart_data_frame_length_p    : 0] data_to_transmit_r;
   reg [uart_baud_rate_length_p     : 0] uart_tick_counter_r;
   reg [high_p                      : 0] next_state_r;
   reg [uart_frame_counter_p        : 0] uart_frame_counter_r;
   reg [uart_frame_counter_p-high_p : 0] data_counter_r;
   reg [uart_frames_p - high_p      : 0] unit_r;
   
   reg 					 start_uart_r;
   reg 					 tx_r;
   reg 					 start_tick_r;
   reg 					 tick_r;
   reg 					 data_available_r;

   always @ (posedge Clk_i or negedge Reset_i)  // This block is responsible to select unit for sensors (Temp or LDR)
     begin
	if(Reset_i == low_p)
	  begin
	     unit_r[7:0] <= 8'hB0;
	  end
	else
	  begin
	     if(Temp_LDR_i == high_p)
	       begin
		  unit_r[7:0] <= temp_p;
	       end
	     else
	       begin
		  unit_r[7:0] <= lux_p;  
	       end
	  end
     end 

   always @ (posedge Clk_i or negedge Reset_i)  // This block is responsible to assert whenever new data is available
     begin
	if(Reset_i == low_p)
	  begin
	     data_available_r <= low_p;
	  end
	else
	  begin
	     data_available_r <= Data_available_i;
	  end
     end

   always @ (posedge Clk_i or negedge Reset_i)  // This block is responsible to sent data frames on uart port
     begin
	if(Reset_i == low_p)
	  begin
	     data_to_transmit_r <= {8'hF2,8'hF5,8'hBF,8'hDF,8'hFF,8'hFF,8'hFC,8'hCF};
	     start_uart_r       <= low_p;
	  end
	else
	  begin
	     if(data_available_r == high_p)
	       begin
		  case(Div_Stages_i)
		    0:
		      begin
			 data_to_transmit_r <= {cr_p,lf_p,unit_r[7:0],space_p,null_p,null_p,null_p,ascii_prefix_p,Data_i[3:0]};
		      end
		    1:
		      begin
			 data_to_transmit_r <= {cr_p,lf_p,unit_r[7:0],space_p,null_p,null_p,ascii_prefix_p,Data_i[7:4],ascii_prefix_p,Data_i[3:0]};
		      end
		    2:
		      begin
			 data_to_transmit_r <= {cr_p,lf_p,unit_r[7:0],space_p,null_p,ascii_prefix_p,Data_i[11:8],ascii_prefix_p,Data_i[7:4],ascii_prefix_p,Data_i[3:0]};
		      end
		    3:
		      begin
			 data_to_transmit_r <= {cr_p,lf_p,unit_r[7:0],space_p,ascii_prefix_p,Data_i[15:12],ascii_prefix_p,Data_i[11:8],ascii_prefix_p,Data_i[7:4],ascii_prefix_p,Data_i[3:0]};
		      end
		    default:
		      begin
			 data_to_transmit_r <= zero_p;
		      end
		  endcase;
		  start_uart_r <= high_p;
	       end
	     else
	       begin
		  data_to_transmit_r <= data_to_transmit_r;
		  start_uart_r       <= low_p;
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
		    data_counter_r        <= low_p;
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
			 tx_r                  <= data_to_transmit_r[(uart_frame_counter_r * uart_data_length_p) + data_counter_r];
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
			 tx_r             <= data_to_transmit_r[((uart_frame_counter_r * uart_data_length_p) + data_counter_r)];
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
		    if(tick_r == high_p && uart_frame_counter_r < uart_data_length_p - single_bit_p)
		      begin
			 next_state_r          <= fsm_uart_start_p;
  			 uart_frame_counter_r  <= uart_frame_counter_r + single_bit_p;
			 start_tick_r          <= start_tick_r;
			 tx_r                  <= low_p;
		      end
		    else if (tick_r == high_p && uart_frame_counter_r == uart_data_length_p - single_bit_p)
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
