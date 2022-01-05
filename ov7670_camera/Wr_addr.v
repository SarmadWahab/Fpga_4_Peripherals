`timescale 1ns / 1ps
`include "give_your_local_location\ov7670_parameters.v"
//////////////////////////////////////////////////////////////////////////////////
// Company:        DIY Projects 
// Engineer:       Sarmad Wahab 
// Create Date:    21:13:03 01/04/2022
// Design Name:    Ov7670 
// Module Name:    Wr_addr (Generate write address for memory to store frame)  
// Target Devices: Xilinx Spartan 6 
// Tool versions:  Design ISE 14.7
//////////////////////////////////////////////////////////////////////////////////
module Wr_addr(
	       input 	     Clk_i,
	       input 	     Reset_i,
	       input 	     Pixel_Available_i,
	       input 	     Vga_Frame_Ack_i,
	       output [14:0] Wr_Addr_o,
	       output 	     Frame_Available_o,
	       output 	     Buff_Locked_o,
	       output 	     Pixel_Available_o
	       );
	 
   
   reg [memory_buffer_address_length_p : 0] wr_addr_r;
   reg [memory_buffer_address_length_p : 0] total_pixel_in_frame_r;
   reg 					    frame_available_r;
   reg 					    buff_locked_r;


   always @ (posedge Clk_i or negedge Reset_i)  // Generate write address for block ram
     begin
	if(Reset_i == low_p)
	  begin
	     wr_addr_r <= 15'd0;
	  end
	else
	  begin
	     if(Pixel_Available_i == high_p && wr_addr_r < pixel_in_one_frame_p)
	       begin
		  wr_addr_r <= wr_addr_r + high_p;
	       end
	     else if ((Pixel_Available_i == high_p || Pixel_Available_i == low_p)  &&  wr_addr_r == pixel_in_one_frame_p)
	       begin
		  wr_addr_r <= zero_p;
	       end
	     else
	       begin
		  wr_addr_r <= wr_addr_r;
	       end
	  end
     end
   
	
always @ (posedge Clk_i or negedge Reset_i)  // It flags, Memory is full whenever we have one frame 
  begin
     if(Reset_i == low_p)
       begin
	  buff_locked_r <= low_p;
       end
     else
       begin
	  if(Vga_Frame_Ack_i == high_p)
	    begin
	       buff_locked_r <= low_p;
	    end
	  else
	    begin
	       if(wr_addr_r == pixel_in_one_frame_p)
		 begin
		    buff_locked_r <= high_p;
		 end
	       else
		 begin
		    buff_locked_r <= buff_locked_r;
		 end
	    end
	  
       end
  end

	
   always @ (posedge Clk_i or negedge Reset_i)  // Counting pixels which are stored 
     begin
	if(Reset_i == low_p)
	  begin
	     total_pixel_in_frame_r <= zero_p;
	  end
	else
	  begin
	     if(Pixel_Available_i == high_p && total_pixel_in_frame_r < pixel_in_one_frame_p)
	       begin
		  total_pixel_in_frame_r <= total_pixel_in_frame_r + high_p;
	       end
	     else if ((Pixel_Available_i == high_p || Pixel_Available_i == low_p) && total_pixel_in_frame_r == pixel_in_one_frame_p)
	       begin
		  total_pixel_in_frame_r <= zero_p;
	       end
	     else
	       begin
		  total_pixel_in_frame_r <= total_pixel_in_frame_r;
	       end
	     
	  end
     end


   always @ (posedge Clk_i or negedge Reset_i)  // Indicates whenever memory has complete frame !!!
     begin
	if(Reset_i == low_p)
	  begin
	     frame_available_r <= low_p;
	  end
	else
	  begin
	     if(Pixel_Available_i == high_p && total_pixel_in_frame_r == pixel_in_one_frame_p - high_p && Vga_Frame_Ack_i == low_p)
	       begin
		  frame_available_r <= high_p;
	       end
	     else if ((Pixel_Available_i == high_p || Pixel_Available_i == low_p) && (total_pixel_in_frame_r == zero_p || total_pixel_in_frame_r > zero_p) && Vga_Frame_Ack_i == high_p)
	       begin
		  frame_available_r <= low_p;
	       end
	     else
	       begin
		  frame_available_r <= frame_available_r;
	       end
	  end
     end


assign Frame_Available_o = frame_available_r;
assign Buff_Locked_o     = buff_locked_r;
assign Wr_Addr_o         = wr_addr_r;
assign Pixel_Available_o = (total_pixel_in_frame_r < pixel_in_one_frame_p) ? Pixel_Available_i : low_p;

endmodule
