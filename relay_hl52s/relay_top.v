////////////////////////////////////////////////////////////////////////////////
// Company: DIY Projects
// Engineer: Sarmad Wahab
//
// Create Date: 11.07.2021
// Design Name: Relay 
// Module Name: top module
// Target Device: Xilinx Spartan 6
// Tool versions: Design ISE 14.7
////////////////////////////////////////////////////////////////////////////////

`include "give_your_local_location\hl52s_parameters.v"




module relay_top
  (
   Clk_i,
   Reset_i,
   Switch_i,
   Relay_o
   );
   
   input  Clk_i,Reset_i,Switch_i;
   output Relay_o;

   wire   relay_w;
   

   relay IP_1 (
   .Clk_i(Clk_i),
   .Reset_i(Reset_i),
   .Switch_i(Switch_i),
   .Relay_o(relay_w)
   );
   
   assign Relay_o = relay_w;
   
   
endmodule
