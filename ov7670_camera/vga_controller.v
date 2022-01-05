`timescale 1ns / 1ps
`include "give_your_local_location\ov7670_parameters.v"
//////////////////////////////////////////////////////////////////////////////////
// Company:        DIY Projects 
// Engineer:       Sarmad Wahab 
// Create Date:    21:13:03 01/04/2022
// Design Name:    Ov7670 
// Module Name:    Vga_controller  
// Target Devices: Xilinx Spartan 6 
// Tool versions:  Design ISE 14.7
//////////////////////////////////////////////////////////////////////////////////
module vga_controller(
		      input 	   Clk_i,
		      input 	   Reset_i,
		      input 	   Enable_i,
		      input [15:0] Pixel_i,
		      output 	   Hsync_o,
		      output 	   Vsync_o,
		      output 	   Read_En_o,
		      output [3:0] R_o,
		      output [3:0] G_o,
		      output [3:0] B_o
    );
	 

   reg 				   hsync_r;
   reg 				   vsync_r;
   reg 				   delay_vsync_r;
   reg 				   delay_enable_r;
   reg 				   enable_rise_edge_r;
   reg 				   rd_en_r;
   reg 				   delay_rd_en_r;
   reg 				   frame_available_r;
   reg 				   data_available_r;
   reg 				   valid_frame_r;

   reg [high_p                     : 0] next_state_r;
   reg [vga_pixel_counter_length_p : 0] pixel_counter_r;
   reg [vga_line_counter_length_p  : 0] line_counter_r;
   reg [vga_rgb_length_p           : 0] r_r;
   reg [vga_rgb_length_p           : 0] g_r;
   reg [vga_rgb_length_p           : 0] b_r;



   always @ (posedge Clk_i or negedge Reset_i)
     begin
	if(Reset_i == low_p)
	  begin
	     valid_frame_r <= low_p;
	  end
	else
	  begin
	     if((line_counter_r  == zero_p || line_counter_r == high_p) && Enable_i == high_p)
	       begin
		  valid_frame_r <= high_p;
	       end
	     else if (line_counter_r == down_border_p  && (Enable_i == high_p || Enable_i == low_p))
	       begin
		  valid_frame_r <= low_p;
	       end
	     else
	       begin
		  valid_frame_r <= valid_frame_r;
	       end
	  end
     end


   always @ (posedge Clk_i or negedge Reset_i)
     begin
	if(Reset_i == low_p)
	  begin
	     delay_rd_en_r <= low_p;
	  end
	else
	  begin
	     delay_rd_en_r <= rd_en_r;
	  end
     end


   always @ (posedge Clk_i or negedge Reset_i)  
     begin
	if(Reset_i == low_p)
	  begin
	     data_available_r <= low_p;
	  end
	else
	  begin
	     if(Enable_i == low_p && delay_enable_r == high_p)
	       begin
		  data_available_r <= high_p;
	       end
	     else
	       begin
		  if(rd_en_r == low_p && delay_rd_en_r == high_p)
		    begin
		       data_available_r <= rd_en_r;
		    end
		  else
		    begin
		       data_available_r <= data_available_r;
		    end
	       end
	  end
     end

   always @ (posedge Clk_i or negedge Reset_i)  // delayed enable signal
     begin
	if(Reset_i == low_p)
	  begin
	     delay_enable_r <= low_p;
	  end
	else
	  begin
	     delay_enable_r <= Enable_i;
	  end
     end
	
   always @ (posedge Clk_i or negedge Reset_i)  // flag the rise edge of enable signal
     begin
	if(Reset_i == low_p)
	  begin
	     enable_rise_edge_r <= low_p;
	  end
	else
	  begin
	     if(Enable_i == high_p)
	       begin
		  enable_rise_edge_r <= high_p;
	       end
	     else
	       begin
		  enable_rise_edge_r <= enable_rise_edge_r;
	       end
	  end
     end


   always @ (posedge Clk_i or negedge Reset_i)  // fsm for VGA 
     begin
	if(Reset_i == low_p)
	  begin
	     next_state_r    <= vga_fsm_idle_p;
	     pixel_counter_r <= zero_p;
	     line_counter_r  <= zero_p;
	  end
	else
	  begin
	     case(next_state_r)
	       vga_fsm_idle_p:
		 begin
		    if(enable_rise_edge_r == high_p)
		      begin
			 next_state_r <= vga_fsm_video_p;
		      end
		    else
		      begin
			 next_state_r <= vga_fsm_idle_p;
		      end
		    pixel_counter_r <= zero_p;
		    line_counter_r  <= zero_p;
		 end
	       vga_fsm_video_p:
		 begin
		    if(pixel_counter_r == vga_total_pixel_p - high_p && line_counter_r == vga_total_lines_p - high_p)
		      begin
			 next_state_r    <= vga_fsm_frame_completed_p;
			 pixel_counter_r <= zero_p;
			 line_counter_r  <= zero_p;
		      end
		    else if (pixel_counter_r == vga_total_pixel_p - high_p && line_counter_r != vga_total_lines_p - high_p)
		      begin
			 next_state_r    <= next_state_r;
			 pixel_counter_r <= zero_p;
			 line_counter_r  <= line_counter_r + high_p;
		      end
		    else
		      begin
			 next_state_r    <= next_state_r;
			 pixel_counter_r <= pixel_counter_r + high_p;
			 line_counter_r  <= line_counter_r;
		      end
		 end
	       vga_fsm_frame_completed_p:
		 begin
		    next_state_r    <= vga_fsm_idle_p;
		    pixel_counter_r <= pixel_counter_r;
		    line_counter_r  <= line_counter_r;
		 end
	       default:
		 begin
		    next_state_r <= next_state_r;
		    pixel_counter_r <= zero_p;
		    line_counter_r  <= zero_p;
		 end
	     endcase;
	  end
     end


   always @ (posedge Clk_i or negedge Reset_i)  // vga hsync signal
     begin
	if(Reset_i == low_p)
	  begin
	     hsync_r <= low_p;
	  end
	else
	  begin
	     if(pixel_counter_r < vga_hsync_sync_p - high_p && enable_rise_edge_r == high_p)
	       begin
		  hsync_r <= high_p;
	       end
	     else
	       begin
		  hsync_r <= low_p;
	       end
	  end
     end
	
   always @ (posedge Clk_i or negedge Reset_i)  // delayed vsync signal
     begin
	if(Reset_i == low_p)
	  begin
	     delay_vsync_r <= low_p;
	  end
	else
	  begin
	     delay_vsync_r <= vsync_r;
	  end
     end


   always @ (posedge Clk_i or negedge Reset_i)  // vga vsync signal
     begin
	if(Reset_i == low_p)
	  begin
	     vsync_r <= low_p;
	  end
	else
	  begin
	     if(line_counter_r < vga_vsync_sync_p - high_p && enable_rise_edge_r == high_p)
	       begin
		  vsync_r <= high_p;
	       end
	     else
	       begin
		  vsync_r <= low_p;
	       end
	  end
     end

   always @ (posedge Clk_i or negedge Reset_i)  //Extract frame data from memory 
     begin
	if(Reset_i == low_p)
	  begin
	     rd_en_r <= low_p;
	  end
	else
	  begin
	     if((pixel_counter_r == left_border_p) && (line_counter_r > up_border_p && line_counter_r < down_border_p && line_counter_r >= 8'd33) && valid_frame_r == high_p)
	       begin
		  rd_en_r <= high_p;
	       end
	     else if (pixel_counter_r == right_border_p && (line_counter_r > up_border_p && line_counter_r < down_border_p) && valid_frame_r == high_p)
	       begin
		  rd_en_r <= low_p;
	       end
	     else
	       begin
		  rd_en_r <= rd_en_r;
	       end
	  end
     end

   always @ (posedge Clk_i or negedge Reset_i)  // Assigns pixel value to RGB of VGA 
     begin
	if(Reset_i == low_p)
	  begin
	     r_r 	  <= zero_p;
	     g_r 	  <= zero_p;
	     b_r     <= zero_p;
	  end
	else
	  begin
	     if(rd_en_r == high_p)
	       begin
		  r_r <= Pixel_i[7:4];
		  g_r <= {Pixel_i[2:0],Pixel_i[15]};
		  b_r <= Pixel_i[12:9]; 
	       end
	     else
	       begin
		  r_r 	  <= zero_p;
		  g_r 	  <= zero_p;
		  b_r     <= zero_p;
	       end
	  end
     end
	
	
assign Read_En_o = rd_en_r;
assign R_o       = r_r;
assign G_o       = g_r;
assign B_o       = b_r;
assign Hsync_o   = !hsync_r;
assign Vsync_o   = !vsync_r;


endmodule
