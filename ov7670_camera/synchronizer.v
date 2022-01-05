`timescale 1ns / 1ps
`include "give_your_local_location\ov7670_parameters.v"
//////////////////////////////////////////////////////////////////////////////////
// Company:        DIY Projects 
// Engineer:       Sarmad Wahab 
// Create Date:    21:13:03 01/04/2022
// Design Name:    Ov7670 
// Module Name:    synchronizer  
// Target Devices: Xilinx Spartan 6 
// Tool versions:  Design ISE 14.7
//////////////////////////////////////////////////////////////////////////////////
module synchronizer(
    input Clk_i,
    input Reset_i,
    input Frame_Available_i,
    output Frame_o
    );
	 

   reg 	   sync_0;
   reg 	   sync_1;
   reg 	   sync_2;


   always @ (posedge Clk_i or negedge Reset_i)  // 2 level shifter 
     begin
	if(Reset_i == low_p)
	  begin
	     sync_0 <= low_p;
	     sync_1 <= low_p;
	     sync_2 <= low_p;
	  end
	else
	  begin
	     sync_0 <= Frame_Available_i;
	     sync_1 <= sync_0;
	     sync_2 <= sync_1;
	  end
     end


assign Frame_o = sync_2;
endmodule
