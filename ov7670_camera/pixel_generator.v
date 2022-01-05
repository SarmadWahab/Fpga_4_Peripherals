`timescale 1ns / 1ps
`include "give_your_local_location\ov7670_parameters.v"
//////////////////////////////////////////////////////////////////////////////////
// Company:        DIY Projects 
// Engineer:       Sarmad Wahab 
// Create Date:    21:13:03 01/04/2022
// Design Name:    Ov7670 
// Module Name:    pixel_generator
// Target Devices: Xilinx Spartan 6 
// Tool versions:  Design ISE 14.7
//////////////////////////////////////////////////////////////////////////////////
module pixel_generator(
		       input 	     PCLK_i,
		       input 	     Reset_i,
		       input 	     Enable_i,
		       input 	     HREF_i,
		       input 	     VSYNC_i,
		       input [7:0]   DATA_i,
		       input 	     Buff_Lock_i,
		       output [15:0] Pixel_o,
		       output 	     Pixel_Available_o
		       );


   reg 				     delay_vsync_r;
   reg 				     vsync_fall_edge_r;
   reg 				     vsync_rise_edge_r;
   reg 				     start_line_counter_r;
   reg 				     delay_href_r;
   reg 				     href_fall_edge_r;
   reg 				     href_rise_edge_r;
   reg 				     delay_pclk_r;
   reg 				     pclk_rise_edge_r;
   reg 				     pclk_fall_edge_r;
   reg 				     pixel_available_r;
   reg 				     allow_data_r;
   reg 				     delay_buff_lock_r;

   reg [pixel_counter_line_counter_length_p : 0] line_counter_r;
   reg [pixel_gen_fsm_length_p              : 0] next_state_r;
   reg [data_length_p                       : 0] first_byte_r;
   reg [data_length_p                       : 0] second_byte_r;
   reg [pixel_counter_length_p              : 0] pixel_counter_r;
   reg [high_p                              : 0] count_four_pixels_r;
   reg [high_p                              : 0] count_four_lines_r;
   reg [pixel_length_p                      : 0] pixel_data_r;
   reg [4                                   : 0] frame_counter_r;




   always @ (posedge PCLK_i or negedge Reset_i)
     begin
	if(Reset_i == low_p)
	  begin
	     frame_counter_r <= zero_p;
	  end
	else
	  begin
	     if(vsync_rise_edge_r == high_p && frame_counter_r < 5'd29)
	       begin
		  frame_counter_r <= frame_counter_r + high_p;
	       end
	     else if (vsync_rise_edge_r == high_p && frame_counter_r == 5'd29)
	       begin
		  frame_counter_r <= zero_p;
	       end
	     else
	       begin
		  frame_counter_r <= frame_counter_r;
	       end
	  end
     end
	


   always @ (posedge PCLK_i or negedge Reset_i)  // Delay VSYNC by one clock cycle
     begin
	if(Reset_i == low_p)
	  begin
	     delay_vsync_r <= delay_vsync_r;
	  end
	else
	  begin
	     delay_vsync_r <= VSYNC_i;
	  end
     end

   always @ (posedge PCLK_i or negedge Reset_i)  // Rise and fall edge of Vsync signal
     begin
	if(Reset_i == low_p)
	  begin
	     vsync_fall_edge_r <= low_p;
	     vsync_rise_edge_r <= low_p;
	  end
	else
	  begin
	     if(VSYNC_i == low_p && delay_vsync_r == high_p && Enable_i == high_p) 
	       begin
		  vsync_fall_edge_r <= high_p;
		  vsync_rise_edge_r <= low_p;
	       end
	     else if (VSYNC_i == high_p && delay_vsync_r == low_p && Enable_i == high_p)
	       begin
		  vsync_fall_edge_r <= low_p;
		  vsync_rise_edge_r <= high_p;
	       end
	     else
	       begin
		  vsync_fall_edge_r <= low_p;
		  vsync_rise_edge_r <= low_p;
	       end
	  end
     end


   always @ (posedge PCLK_i or negedge Reset_i) // When to start line counting 
     begin
	if(Reset_i == low_p)
	  begin
	     start_line_counter_r <= low_p;
	  end
	else
	  begin
	     if(vsync_fall_edge_r == high_p)
	       begin
		  start_line_counter_r <= high_p;
	       end
	     else if (vsync_rise_edge_r == high_p)
	       begin
		  start_line_counter_r <= low_p;
	       end
	     else
	       begin
		  start_line_counter_r <= start_line_counter_r;
	       end
	  end
     end


   always @ (posedge PCLK_i or negedge Reset_i)  // Href is delayed one clock cycle
     begin
	if(Reset_i == low_p)
	  begin
	     delay_href_r <= low_p;
	  end
	else
	  begin
	     delay_href_r <= HREF_i;
	  end
     end
   
	
   always @ (posedge PCLK_i or negedge Reset_i)
     begin
	if(Reset_i == low_p)
	  begin
	     href_fall_edge_r <= low_p;
	     href_rise_edge_r <= low_p;
	  end
	else
	  begin
	     if(HREF_i == low_p && delay_href_r == high_p && Enable_i == high_p) 
	       begin
		  href_fall_edge_r <= high_p;
		  href_rise_edge_r <= low_p;
	       end
	     else if (HREF_i == high_p && delay_href_r == low_p && Enable_i == high_p)
	       begin
		  href_rise_edge_r <= high_p;
		  href_fall_edge_r <= low_p;
	       end
	     else
	       begin
		  href_fall_edge_r <= low_p;
		  href_rise_edge_r <= low_p;
	       end
	  end
     end

   always @ (posedge PCLK_i or negedge Reset_i)  // Counter for lines
     begin
	if(Reset_i == low_p)
	  begin
	     line_counter_r <= zero_p;
	  end
	else
	  begin
	     if(start_line_counter_r == high_p && href_fall_edge_r == high_p)
	       begin
		  line_counter_r <= line_counter_r + high_p;
	       end
	     else if (start_line_counter_r == high_p && href_fall_edge_r != high_p)
	       begin
		  line_counter_r <= line_counter_r;
	       end
	     else
	       begin
		  line_counter_r <= zero_p;
	       end
	  end
     end
	
	
   always @ (posedge PCLK_i or negedge Reset_i)  // Filter or pixels/4
     begin
	if(Reset_i == low_p)
	  begin
	     count_four_pixels_r <= zero_p;
	  end
	else
	  begin
	     if(pixel_available_r == high_p)
	       begin
		  count_four_pixels_r <= count_four_pixels_r + high_p;
	       end
	     else
	       begin
		  count_four_pixels_r <= count_four_pixels_r;
	       end
	  end
     end
   
   always @ (posedge PCLK_i or negedge Reset_i)  // Filter or lines/4
     begin
	if(Reset_i == low_p)
	  begin
	     count_four_lines_r <= zero_p;
	  end
	else
	  begin
	     if(href_fall_edge_r == high_p)
	       begin
		  count_four_lines_r <= count_four_lines_r + high_p;
	       end
	     else
	       begin
		  count_four_lines_r <= count_four_lines_r;
	       end
	  end
     end
		
   always @ (posedge PCLK_i or negedge Reset_i)
     begin
	if(Reset_i == low_p)
	  begin
	     delay_buff_lock_r <= low_p;
	  end
	else
	  begin
	     delay_buff_lock_r <= Buff_Lock_i;
	  end
     end
   
	
   always @ (posedge PCLK_i or negedge Reset_i)  // filter for frames
     begin
	if(Reset_i == low_p)
	  begin
	     allow_data_r <= low_p;
	  end
	else
	  begin
	     if(Buff_Lock_i == low_p && delay_buff_lock_r == high_p && line_counter_r > zero_p)
	       begin
		  allow_data_r <= high_p;
	       end
	     else if (vsync_fall_edge_r == high_p && allow_data_r == high_p)
	       begin
		  allow_data_r <= low_p;
	       end
	     else
	       begin
		  allow_data_r <= allow_data_r;
	       end
	  end
     end


   always @ (posedge PCLK_i or negedge Reset_i)  // Extracting pixels from camera 
     begin
	if(Reset_i == low_p)
	  begin
	     next_state_r  		<= pixel_gen_fsm_idle_p;
	     first_byte_r  		<= zero_p;
	     second_byte_r     <= zero_p;
	     pixel_available_r <= low_p;
	     pixel_counter_r   <= zero_p;
	  end
	else
	  begin
	     case(next_state_r)
	       pixel_gen_fsm_idle_p:
		 begin
		    if((line_counter_r > pixel_gen_back_porch && line_counter_r <= number_of_lines_p) && href_rise_edge_r == high_p)
		      begin
			 next_state_r <= pixel_gen_fsm_first_byte_p;
		      end
		    else
		      begin
			 next_state_r <= pixel_gen_fsm_idle_p;
		      end
		    first_byte_r  		<= zero_p;
		    second_byte_r 		<= zero_p;
		    pixel_available_r <= low_p;
		    pixel_counter_r   <= zero_p;
		 end
	       pixel_gen_fsm_first_byte_p:
		 begin
		    next_state_r      <= pixel_gen_fsm_second_byte_p;
		    first_byte_r      <= DATA_i;
		    second_byte_r 		<= second_byte_r;
		    pixel_available_r <= low_p;
		    pixel_counter_r   <= pixel_counter_r;
		 end
	       pixel_gen_fsm_second_byte_p:
		 begin
		    if(pixel_counter_r < number_of_pixels_in_row_p)
		      begin
			 next_state_r      <= pixel_gen_fsm_first_byte_p;
			 second_byte_r 	   <= DATA_i;
			 pixel_available_r <= high_p;
			 pixel_counter_r   <= pixel_counter_r + high_p;
		      end
		    else
		      begin
			 next_state_r      <= pixel_gen_fsm_stop_p;
			 second_byte_r     <= second_byte_r;
			 pixel_available_r <= low_p;
			 pixel_counter_r   <= zero_p;
		      end
		    first_byte_r <= first_byte_r;
		 end
	       pixel_gen_fsm_stop_p:
		 begin
		    if(line_counter_r < number_of_lines_p)
		      begin
			 next_state_r <= pixel_gen_fsm_idle_p;
		      end
		    else
		      begin
			 if(vsync_rise_edge_r == high_p)
			   begin
			      next_state_r <= pixel_gen_fsm_idle_p;
			   end
			 else
			   begin
			      next_state_r <= next_state_r;
			   end
			 
		      end
		    first_byte_r      <= first_byte_r;
		    second_byte_r     <= second_byte_r;
		    pixel_available_r <= pixel_available_r;
		    pixel_counter_r   <= pixel_counter_r;
		 end
	     endcase;
	  end
     end

assign Pixel_o           = {second_byte_r,first_byte_r};
assign Pixel_Available_o = (count_four_pixels_r == 2'd0 && count_four_lines_r == 2'd0 && allow_data_r == low_p && Buff_Lock_i == low_p) ? pixel_available_r : low_p;

endmodule
