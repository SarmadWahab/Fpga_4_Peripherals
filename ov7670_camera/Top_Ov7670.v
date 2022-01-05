`timescale 1ns / 1ps
`include "give_your_local_location\ov7670_parameters.v"
//////////////////////////////////////////////////////////////////////////////////
// Company:        DIY Projects 
// Engineer:       Sarmad Wahab 
// Create Date:    21:13:03 01/04/2022
// Design Name:    Ov7670 
// Module Name:    Top Module  
// Target Devices: Xilinx Spartan 6 
// Tool versions:  Design ISE 14.7
//////////////////////////////////////////////////////////////////////////////////
module Top_Ov7670(
		  input        Clk_i,
		  input        Reset_i,
		  input        Switch_i,
		  input        Strobe_i,
		  input        Href_i,
		  input        Pclk_i,
		  input        Vsync_i,
		  input [7:0]  Pixel_i,
		  output       Xclk_o,
		  output       Reset_o,
		  output       Pwdn_o,
		  output       Scl_o,
		  inout        Sda_io,
		  output [3:0] R_o,
		  output [3:0] G_o,
		  output [3:0] B_o,
		  output       Hsync_o,
		  output       Vsync_o,
		  output       Led_o,
		  output       Copy_Clk_o
    );
	 
	 

   wire 		       clk_24_Mhz_w;
   wire 		       clk_25_Mhz_w;
   wire 		       reset_w;
   wire 		       locked_w;
   wire 		       scl_w;
   wire 		       sda_w;
   wire 		       config_done_w;
   wire 		       config_done_1_w;
   wire 		       pixel_available_w;
   wire 		       pixel_available_1_w;
   wire 		       frame_available_w;
   wire 		       frame_available_1_w;
   wire 		       hsync_w;
   wire 		       vsync_w;
   wire 		       read_en_w;
   wire 		       rd_en_w;
   wire 		       mem_ack_w;
   wire 		       xclk_w;
   reg 			       allow_memory_r;
   reg 			       next_state_r;
   reg 			       delay_vsync_r;
   wire 		       buff_lock_w;

   wire [14:0] 		       wr_addr_w;
   wire [14:0] 		       rd_addr_w;
   wire [15:0] 		       pixel_w;
   wire [15:0] 		       stored_pixel_w;
   wire [3:0] 		       r_w;
   wire [3:0] 		       g_w;
   wire [3:0] 		       b_w;

assign pclk_r = Pclk_i;
   PLL IP_0(                                       // PLL used to generate clock for VGA and Camera
	    .CLK_IN1(Clk_i),      
	    .CLK_OUT1(clk_24_Mhz_w),     
	    .CLK_OUT2(clk_25_Mhz_w),     
	    .RESET(reset_w),
	    .LOCKED(locked_w));   

   sccb_controller IP_1 (                         // This IP is used to configure camera 
			 .Clk_i(clk_24_Mhz_w), 
			 .Reset_i(Reset_i), 
			 .Switch_i(Switch_i), 
			 .SCL_o(scl_w), 
			 .SDA_io(sda_w), 
			 .Config_Done_o(config_done_w)
			 );
	 
   synchronizer IP_2 (                            // This IP is used to perform synchronization among different clock domains
		      .Clk_i(Pclk_i), 
		      .Reset_i(Reset_i), 
		      .Frame_Available_i(config_done_w), 
		      .Frame_o(config_done_1_w)
		      );

   pixel_generator IP_3 (                         // Extract pixels from camera
			 .PCLK_i(Pclk_i), 
			 .Reset_i(Reset_i), 
			 .Enable_i(config_done_1_w), 
			 .HREF_i(Href_i), 
			 .VSYNC_i(Vsync_i), 
			 .DATA_i(Pixel_i),
			 .Buff_Lock_i(buff_lock_w),
			 .Pixel_o(pixel_w), 
			 .Pixel_Available_o(pixel_available_w)
			 );
	

	
   Wr_addr IP_4 (                                 // This IP generates write address from frame
		 .Clk_i(Pclk_i), 
		 .Reset_i(Reset_i), 
		 .Pixel_Available_i(pixel_available_w),  
		 .Vga_Frame_Ack_i(mem_ack_1_w),
		 .Wr_Addr_o(wr_addr_w),
		 .Frame_Available_o(frame_available_w),
		 .Buff_Locked_o(buff_lock_w),
		 .Pixel_Available_o(pixel_available_1_w)
		 );
	 
   synchronizer IP_5 (                            // This IP is used to perform synchronization among different clock domains
		      .Clk_i(clk_25_Mhz_w), 
		      .Reset_i(Reset_i), 
		      .Frame_Available_i(frame_available_w), 
		      .Frame_o(frame_available_1_w)
		      );
	 
  
   Bram IP_6 (                                    // Block ram used to store frame 
	      .clka(Pclk_i), 
	      .wea(!buff_lock_w), 
	      .addra(wr_addr_w), 
	      .dina(pixel_w), 
	      .clkb(clk_25_Mhz_w), 
	      .enb(1'b1),
	      .addrb(rd_addr_w), 
	      .doutb(stored_pixel_w) 
	      );


   Rd_Addr IP_7 (                                 // This IP generates read address from frame
		 .Clk_i(clk_25_Mhz_w), 
		 .Reset_i(Reset_i), 
		 .Frame_Available_i(frame_available_1_w), 
		 .Vga_Ready_i(read_en_w), 
		 .Rd_En_o(rd_en_w), 
		 .Mem_Ack_o(mem_ack_w),
		 .Rd_Addr_o(rd_addr_w)
		 );
	
   vga_controller IP_8 (                          // This is VGA IP used to display video on Monitor
			.Clk_i(clk_25_Mhz_w),
			.Reset_i(Reset_i),
			.Enable_i(frame_available_1_w), 
			.Pixel_i(stored_pixel_w), 
			.Hsync_o(hsync_w), 
			.Vsync_o(vsync_w), 
			.Read_En_o(read_en_w), 
			.R_o(r_w), 
			.G_o(g_w), 
			.B_o(b_w)
			);
	 
   synchronizer IP_9 (                            // This IP is used to perform synchronization among different clock domains
		      .Clk_i(Pclk_i), 
		      .Reset_i(Reset_i), 
		      .Frame_Available_i(mem_ack_w), 
		      .Frame_o(mem_ack_1_w)
		      );
	 
   ODDR2 #(                                       // This IP is used to output clock on pin (XCLK)
	   .DDR_ALIGNMENT("NONE"),
	   .INIT(1'b0),    
	   .SRTYPE("SYNC")
	   ) clock_forward_inst_2 (
				   .Q(xclk_w),    
				   .C0(clk_24_Mhz_w),  
				   .C1(~clk_24_Mhz_w),
				   .CE(1'b1),      
				   .D0(1'b0), 
				   .D1(1'b1), 
				   .R(1'b0),  
				   .S(1'b0)   
				   );
   assign Xclk_o     = xclk_w;
   assign Reset_o    = high_p;
   assign Pwdn_o     = low_p;
   assign Scl_o      = scl_w;
   assign Sda_io     = sda_w;
   assign R_o        = r_w;
   assign G_o        = g_w;
   assign B_o        = b_w;
   assign Vsync_o    = vsync_w;
   assign Hsync_o    = hsync_w;
   assign Led_o      = config_done_w;
   assign Copy_Clk_o = pclk_r;

endmodule
