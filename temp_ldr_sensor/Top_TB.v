`timescale 1ns / 1ps
`include "give_your_local_location\Tmp_LDR_parameters.v"

////////////////////////////////////////////////////////////////////////////////
// Company:        DIY Projects 
// Engineer:       Sarmad Wahab 
// Create Date:    19:09:41 09/19/2021 
// Design Name:    Temperature & LDR sensor
// Module Name:    Top_TB
// Target Devices: Xilinx Spartan 6
// Tool versions:  Design ISE 14.7
////////////////////////////////////////////////////////////////////////////////

module Top_TB;

	parameter temp_data_p = 12'd43;
	// Inputs
	reg Clk_i;
	reg Reset_i;
	reg Switch_i;
	reg Temp_LDR_i;
	reg MISO_i;

	// Outputs
	wire MOSI_o;
	wire SCLK_o;
	wire CS_o;
	wire Tx_o;

	// Instantiate the Unit Under Test (UUT)
	Top_Tmp_Ldr uut (
		.Clk_i(Clk_i), 
		.Reset_i(Reset_i), 
		.Switch_i(Switch_i), 
		.Temp_LDR_i(Temp_LDR_i), 
		.MISO_i(MISO_i), 
		.MOSI_o(MOSI_o), 
		.SCLK_o(SCLK_o), 
		.CS_o(CS_o), 
		.Tx_o(Tx_o)
	);

   always
     begin
	Clk_i = 0;
	#10;
	Clk_i = 1;
	#10;
     end
		
   always @ (posedge Clk_i or negedge Reset_i)
     begin
	if(Reset_i == 1'b0)
	  begin
	     MISO_i <= 1'bz;
	  end
	else
	  begin
	     if(uut.IP_1.next_state_r == 3'd3 && uut.IP_1.spi_internal_counter_r > 2'd1)
	       begin
		  MISO_i <= temp_data_p[uut.IP_1.spi_internal_counter_r - 2'd2];
	       end
	     else
	       begin
		  MISO_i <= MISO_i;
	       end
	  end
     end


   initial begin
      // Initialize Inputs
      
      Reset_i = 0;
      Switch_i = 0;
      Temp_LDR_i = 0;
      //MISO_i = 0;

      // Wait 100 ns for global reset to finish
      #100;
      Reset_i = 1;
      Switch_i = 1;
      Temp_LDR_i = 0;
      
      
      // Add stimulus here

   end
      
endmodule

