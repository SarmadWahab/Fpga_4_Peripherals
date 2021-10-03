`include "give_your_local_location\Tmp_LDR_parameters.v"
`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company:        DIY Projects 
// Engineer:       Sarmad Wahab 
// Create Date:    19:09:41 09/19/2021 
// Design Name:    Temperature & LDR sensor
// Module Name:    Top_Tmp_Ldr  
// Target Devices: Xilinx Spartan 6
// Tool versions:  Design ISE 14.7
////////////////////////////////////////////////////////////////////////////////

module Top_Tmp_Ldr(
    input Clk_i,
    input Reset_i,
    input Switch_i,
    input Temp_LDR_i,
    input MISO_i,
    output MOSI_o,
    output SCLK_o,
    output CS_o,
    output Tx_o,
    output Led_o
    );
 
	 

   wire              cs_w;
   wire              sclk_w;
   wire              mosi_w;
   wire              tx_w;

   wire              data_available_0_w;
   wire              data_available_1_w;

   wire [high_p               : 0] div_stages_w;
   wire [data_length_for_IP_0 : 0] data_0_w;
   wire [data_length_for_IP_1 : 0] data_1_w;
   wire                            debug_w;

spi_controller IP_1 (                         // IP_1 is SPI interface to DAC to retrieve data from Temperature sensor and LDR sensor
    .Clk_i(Clk_i), 
    .Reset_i(Reset_i), 
    .Switch_i(Switch_i), 
    .Temp_LDR_i(Temp_LDR_i), 
    .MISO_i(MISO_i), 
    .CS_o(cs_w), 
    .SCLK_o(sclk_w), 
    .MOSI_o(mosi_w), 
    .Data_Available_o(data_available_0_w), 
    .Data_o(data_0_w)
    );


data_converter IP_2 (                         // IP_2 is used to conver the data from sensors to ascii format
    .Clk_i(Clk_i), 
    .Reset_i(Reset_i), 
    .Temp_LDR_i(Temp_LDR_i), 
    .Data_Available_i(data_available_0_w), 
    .Data_i(data_0_w), 
    .Data_Available_o(data_available_1_w), 
    .Data_o(data_1_w), 
    .Div_Stages_o(div_stages_w),
    .Unused_bits_o(debug_w)
    );
	 
uart_transmission IP_3 (                      // IP_3 is used to send the ascii data on uart port
    .Clk_i(Clk_i), 
    .Reset_i(Reset_i), 
    .Data_available_i(data_available_1_w), 
    .Data_i(data_1_w), 
    .Temp_LDR_i(Temp_LDR_i), 
    .Div_Stages_i(div_stages_w), 
    .Tx_o(tx_w)
    );	

assign CS_o   = cs_w;
assign SCLK_o = sclk_w;
assign MOSI_o = mosi_w;
assign Tx_o   = tx_w;
assign Led_o  = debug_w;

endmodule
