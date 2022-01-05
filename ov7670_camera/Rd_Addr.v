`timescale 1ns / 1ps
`include "give_your_local_location\ov7670_parameters.v"
//////////////////////////////////////////////////////////////////////////////////
// Company:        DIY Projects 
// Engineer:       Sarmad Wahab 
// Create Date:    21:13:03 01/04/2022
// Design Name:    Ov7670 
// Module Name:    Rd_Addr (Generate read address for memory to store frame)  
// Target Devices: Xilinx Spartan 6 
// Tool versions:  Design ISE 14.7
//////////////////////////////////////////////////////////////////////////////////
module Rd_Addr(
	       input 	     Clk_i,
	       input 	     Reset_i,
	       input 	     Frame_Available_i,
	       input 	     Vga_Ready_i,
	       output 	     Rd_En_o,
	       output 	     Mem_Ack_o,
	       output [14:0] Rd_Addr_o
	       );
   
   reg 			                    rd_en_r;
   reg 			                    mem_ack_r;
   reg [memory_buffer_address_length_p : 0] rd_addr_r;
   reg [memory_buffer_address_length_p : 0] total_pixel_in_frame_r;
   reg [high_p                         : 0] next_state_r;




   always @ (posedge Clk_i or negedge Reset_i)  // Generate read address from block ram
     begin
	if(Reset_i == low_p)
	  begin
	     rd_addr_r <= zero_p;
	  end
	else
	  begin
	     if(Vga_Ready_i == high_p && rd_addr_r < pixel_in_one_frame_p)
	       begin
		  rd_addr_r <= rd_addr_r + high_p;
	       end
	     else if (Vga_Ready_i == low_p && rd_addr_r == pixel_in_one_frame_p)
	       begin
		  rd_addr_r <= zero_p;
	       end
	     else
	       begin
		  rd_addr_r <= rd_addr_r;
	       end
	  end
     end
	
	
   always @ (posedge Clk_i or negedge Reset_i)       // Frame is extracted 
     begin
	if(Reset_i == low_p)
	  begin
	     mem_ack_r <= low_p;
	  end
	else
	  begin
	     if(rd_addr_r == pixel_in_one_frame_p)
	       begin
		  mem_ack_r <= high_p;
	       end
	     else
	       begin
		  mem_ack_r <= low_p;
	       end
	  end
     end


   always @ (posedge Clk_i or negedge Reset_i)  // FSM to generate read enable for block ram !!! 
     begin
	if(Reset_i == low_p)
	  begin
	     next_state_r           <= rd_addr_fsm_idle_p;
	     total_pixel_in_frame_r <= zero_p;
	     rd_en_r              <= low_p;
	  end
	else
	  begin
	     case(next_state_r)
	       rd_addr_fsm_idle_p:
		 begin
		    if(Frame_Available_i == high_p)
		      begin
			 next_state_r <= rd_addr_fsm_extract_frame_data_p;
		      end
		    else
		      begin
			 next_state_r <= rd_addr_fsm_idle_p;
		      end
		    total_pixel_in_frame_r <= zero_p;
		    rd_en_r              <= low_p;
		 end
	       rd_addr_fsm_extract_frame_data_p:
		 begin
		    if(total_pixel_in_frame_r ==  pixel_in_one_frame_p && Vga_Ready_i == high_p) 
		      begin
			 next_state_r           <= rd_addr_fsm_idle_p;
			 total_pixel_in_frame_r <= zero_p;
			 rd_en_r                <= low_p;
		      end
		    else if (total_pixel_in_frame_r < pixel_in_one_frame_p && Vga_Ready_i == high_p)  
		      begin
			 next_state_r           <= next_state_r;
			 total_pixel_in_frame_r <= total_pixel_in_frame_r + high_p;
			 rd_en_r                <= high_p;
		      end
		    else
		      begin
			 next_state_r           <= next_state_r;
			 total_pixel_in_frame_r <= total_pixel_in_frame_r;
			 rd_en_r                <= low_p;
		      end
		 end
	       default:
		 begin
		    next_state_r           <= rd_addr_fsm_idle_p;
		    total_pixel_in_frame_r <= zero_p;
		    rd_en_r                <= low_p;
		    
		 end
	     endcase;
	  end
     end



assign Rd_En_o   = rd_en_r;
assign Mem_Ack_o = mem_ack_r;
assign Rd_Addr_o = rd_addr_r;



endmodule
