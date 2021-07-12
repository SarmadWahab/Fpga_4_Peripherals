////////////////////////////////////////////////////////////////////////////////
// Company: DIY Projects
// Engineer: Sarmad Wahab
//
// Create Date: 11.07.2021
// Design Name: Ultrasonic sensor 
// Module Name: Uart module (used to display ultrasonic sensor data on PC)
// Target Device: Xilinx Spartan 6
// Tool versions: Design ISE 14.7
////////////////////////////////////////////////////////////////////////////////
`include "give_your_local_location\hcsr04_parameters.v"

module ultrasonic_sensor_uart_transmission
  (
   Clk_i,
   Reset_i,
   Data_available_i,
   Data_i,
   cm_or_inch_i,
   Tx_o
   );

 
   input                        Clk_i, Reset_i, Data_available_i,cm_or_inch_i;
   input [data_length_p-1   :0] Data_i;
   output 		        Tx_o;

   reg [uart_max_frame_p-1  :0] data_to_transmit_r;
   reg [single_bit_p        :0] next_state_r;
   reg [data_length_p       :0] uart_tick_counter_r;
   reg [fsm_uart_stop_p-1   :0] uart_frame_counter_r;
   reg [fsm_uart_stop_p     :0] data_counter_r;
   reg                          tick_r;
   reg                          start_tick_r;
   reg [unit_size_p-1       :0] unit_r;
   reg [single_bit_p        :0] frame_adjust_r;
   reg tx_r;
   

  always @ (posedge Clk_i or negedge Reset_i)  // This block is responsible to select unit for distance
    begin
       if(Reset_i == low_p)
	 begin
	    unit_r <= some_bits_one_p;
	 end
       else
	 begin
	    if(cm_or_inch_i == high_p)
	      begin
		 unit_r <= in_p;
	      end
	    else
	      begin
		 unit_r <= cm_p;  
	      end
	 end
    end 

  always @ (posedge Clk_i or negedge Reset_i)  // This block is responsible to print the data on uart depending on their format (e.g, 10cm instead of 010 cm or 1 cm instead of 001 cm)
    begin
       if(Reset_i == low_p)
	 begin
	    frame_adjust_r   <= low_p;
	 end
       else
	 begin
	    if(Data_i[data_length_p-9:0] == low_p && Data_i[data_length_p-5:data_length_p-8] != low_p)
	      begin
		 frame_adjust_r   <= single_bit_p;
	      end
	    else if(Data_i[data_length_p-9:0] == low_p && Data_i[data_length_p-5:data_length_p-8] == low_p)
	      begin
		 frame_adjust_r   <= single_bit_p << single_bit_p;
	      end
	    else
	      begin
		 frame_adjust_r   <= low_p;
	      end
	 end
    end

  always @ (posedge Clk_i or negedge Reset_i)  // This block is responsible to update the data frame whenever new data is available
	 begin
	    if(Reset_i == low_p)
	      begin
		 data_to_transmit_r <= {16'hF5F2,16'h0000,16'hDFC0,16'hC0C0}; // A number to avoid optimization warnings !!! 
	      end
	    else
	      begin
		 if(Data_available_i == high_p)
		   begin
		      data_to_transmit_r <= {cr_lf_p, unit_r, space_p, ascii_prefix, Data_i[data_length_p-1:data_length_p-4], ascii_prefix, Data_i[data_length_p-5:data_length_p-8], ascii_prefix,Data_i[data_length_p-9:0]};
		   end
		 else
		   begin
		      data_to_transmit_r <= data_to_transmit_r;
		   end
		 
	      end
	 end



    always @ (posedge Clk_i or negedge Reset_i)  // FSM for Uart
     begin
	if(Reset_i == low_p)
	  begin
	     next_state_r                      <= fsm_uart_idle_p;
	     data_counter_r                    <= low_p;
             uart_frame_counter_r              <= low_p;
	     start_tick_r                      <= low_p;
	     tx_r                              <= high_p;
	  end
	else
	  begin
	     case(next_state_r)
	       fsm_uart_idle_p:
		 begin
		    if(Data_available_i == high_p)
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
		    uart_frame_counter_r       <= frame_adjust_r;
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
