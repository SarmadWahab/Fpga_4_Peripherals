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
