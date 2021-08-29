`timescale 1ns / 1ps
`include "C:\Users\Sarmad Wahab\Desktop\adxl345_parameters.v"
//////////////////////////////////////////////////////////////////////////////////
// Company:        DIY Projects
// Engineer:       Sarmad Wahab
// Create Date:    22:53:36 08/26/2021 
// Design Name:    Adxl345 Sensor
// Module Name:    uart_transmission  
// Target Devices: Xilinx Spartan 6
// Tool versions:  Design ISE 14.7
//////////////////////////////////////////////////////////////////////////////////
module uart_transmission(
	Clk_i,
	Reset_i,
	Data_Available_i,
	Data_i,
	Tx_o
    );
	 
	
      input                                      Clk_i, Reset_i, Data_Available_i;
   input [characteristics_mantissa_length_p : 0] Data_i;
   output 			                 Tx_o;

   reg                                           tick_r;
   reg                                           start_tick_r;
   reg                                           tx_r;

   reg  [uard_baud_rate_length_p            : 0] uart_tick_counter_r;
   reg  [uart_data_frame_length_p           : 0] data_frame_r;
   reg  [high_p                             : 0] next_state_r;
   reg  [uart_frame_counter_p               : 0] uart_frame_counter_r;
   reg  [uart_frame_counter_p-high_p        : 0] data_counter_r;
   reg  [high_p                             : 0] characteristics_x_r;
   reg  [high_p                             : 0] characteristics_y_r;
   reg  [high_p                             : 0] characteristics_z_r;
   
   wire [eight_clock_cycles_p-high_p        : 0] sign_x_r;
   wire [eight_clock_cycles_p-high_p        : 0] sign_y_r;
   wire [eight_clock_cycles_p-high_p        : 0] sign_z_r;
  

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
 
   always @ (posedge Clk_i or negedge Reset_i)  // This block send frames on UART port
     begin
	if(Reset_i == low_p)
	  begin
		  data_frame_r[31:0]    <= 32'hCFFFC287;
		  data_frame_r[63:32]   <= 32'hDFCFC2D1;
		  data_frame_r[95:64]   <= 32'hCFFFC286;
		  data_frame_r[127:96]  <= 32'hDFCFC2D1;
		  data_frame_r[159:128] <= 32'hCFFFC285;
		  data_frame_r[191:160] <= 32'hF5C7C2D1;
		  data_frame_r[199:192] <= 8'hF2;
	  end
	else
	  begin
	     if(Data_Available_i == high_p)
	       begin
		   data_frame_r <= {cr_p,lf_p,ascii_prefix_p,Data_i[19:16],ascii_prefix_p,Data_i[23:20],dot_p,ascii_prefix_p,2'b00,characteristics_z_r,sign_z_r,equal_p,z_p,space_p,ascii_prefix_p,Data_i[11:8],ascii_prefix_p,Data_i[15:12],dot_p,ascii_prefix_p,2'b00,characteristics_y_r,sign_y_r,equal_p,y_p,space_p,ascii_prefix_p,Data_i[3:0],ascii_prefix_p,Data_i[7:4],dot_p,ascii_prefix_p,2'b00,characteristics_x_r,sign_x_r,equal_p,x_p};
	       end
	     else
	       begin
				data_frame_r <= data_frame_r;
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
		    if(Data_Available_i == high_p)
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
	  
   always @ (posedge Clk_i or negedge Reset_i)  // This block is responsbile to detect negative binary and produce inverted 2's complement number 
     begin
	if(Reset_i == low_p)
	  begin
	     characteristics_x_r <= zero_p;
	  end
	else
	  begin
	     if(Data_i[26])
	       begin
		  case(Data_i[25:24])
		    0:
		      begin
			 characteristics_x_r <= 2'b00;
		      end
		    1:
		      begin
			 characteristics_x_r <= 2'b11;
		      end
		    2:
		      begin
			 characteristics_x_r <= 2'b10;
		      end
		    3:
		      begin
			 characteristics_x_r <= 2'b01;
		      end
		  endcase
	       end
	     else
	       begin
		  characteristics_x_r <= Data_i[25:24];
	       end
	  end
     end
		
   always @ (posedge Clk_i or negedge Reset_i)  // This block is responsbile to detect negative binary and produce inverted 2's complement number 
     begin
	if(Reset_i == low_p)
	  begin
	     characteristics_y_r <= zero_p;
	  end
	else
	  begin
	     if(Data_i[29])
	       begin
		  case(Data_i[28:27])
		    0:
		      begin
			 characteristics_y_r <= 2'b00;
		      end
		    1:
		      begin
			 characteristics_y_r <= 2'b11;
		      end
		    2:
		      begin
			 characteristics_y_r <= 2'b10;
		      end
		    3:
		      begin
			 characteristics_y_r <= 2'b01;
		      end
		  endcase
	       end
	     else
	       begin
		  characteristics_y_r <= Data_i[28:27];
	       end
	  end
     end
   
   always @ (posedge Clk_i or negedge Reset_i)  // This block is responsbile to detect negative binary and produce inverted 2's complement number 
     begin
	if(Reset_i == low_p)
	  begin
	     characteristics_z_r <= zero_p;
	  end
	else
	  begin
	     if(Data_i[32])
	       begin
		  case(Data_i[31:30])
		    0:
		      begin
			 characteristics_z_r <= 2'b00;
		      end
		    1:
		      begin
			 characteristics_z_r <= 2'b11;
		      end
		    2:
		      begin
			 characteristics_z_r <= 2'b10;
		      end
		    3:
		      begin
			 characteristics_z_r <= 2'b01;
		      end
		  endcase
	       end
	     else
	       begin
		  characteristics_z_r <= Data_i[31:30];
	       end
	  end
     end
   
		
	       
 assign sign_x_r = Data_i[26] ? minus_p : 1'b0;
 assign sign_y_r = Data_i[29] ? minus_p : 1'b0;
 assign sign_z_r = Data_i[32] ? minus_p : 1'b0;
 assign Tx_o     = tx_r;

endmodule
