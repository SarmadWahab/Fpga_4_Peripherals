`timescale 1ns / 1ps
`include "give_your_local_location\adxl345_parameters.v"
//////////////////////////////////////////////////////////////////////////////////
// Company:        DIY Projects
// Engineer:       Sarmad Wahab
// Create Date:    20:21:50 08/26/2021
// Design Name:    Adxl345 Sensor
// Module Name:    Adx345_Top
// Target Devices: Xilin Spartan 6
// Tool versions:  Design ISE 14.7
//////////////////////////////////////////////////////////////////////////////////
module Adx345_Top(
	 Clk_i,
	 Reset_i,
	 Switch_i,
	 SDA_io,
	 SCL_o, 
	 Tx_o,
	 CS_o,
	 Debug_o,
	 Unused_o,
	 X_o,
	 Y_o,
	 Z_o,
	 Data_Available_o
    );

   input 		                               Clk_i, Reset_i, Switch_i;
   inout                                               SDA_io;
   output                                              SCL_o, Tx_o, CS_o, Debug_o, Unused_o, Data_Available_o;
   output signed [offset_p                        : 0] X_o;
   output signed [offset_p                        : 0] Y_o;
   output signed [offset_p                        : 0] Z_o;
   
   wire 		                               scl_w;
   wire 		                               cs_w;
   wire 		                               debug_w;
   wire 		                               unused_bits_w;
   wire 		                               tx_w;
   wire 		                               data_available_0_w;
   wire 		                               data_available_1_w;

   wire        [characteristics_mantissa_length_p : 0] data_w;	 
   wire signed [offset_p                          : 0] x_w;
   wire signed [offset_p                          : 0] y_w;
   wire signed [offset_p                          : 0] z_w;




i2c_controller IP_0 (                        // This IP is responsible to configure Adxl345 Via I2C protocl (Performs single read, single write & burst read)
    .Clk_i(Clk_i), 
    .Reset_i(Reset_i), 
    .Switch_i(Switch_i), 
    .SDA_io(SDA_io), 
    .SCL_o(scl_w), 
    .CS_o(cs_w), 
    .X_o(x_w), 
    .Y_o(y_w), 
    .Z_o(z_w), 
    .Data_Available_o(data_available_0_w), 
    .Debug_o(debug_w)
    );
	 
adxl345_data_converter IP_1 (                // This IP is responsible to convert the data from Adxl345 to ASCII format which will be sent later on UART port (using 2g)
    .Clk_i(Clk_i), 
    .Reset_i(Reset_i), 
    .Data_Available_i(data_available_0_w), 
    .X_i(x_w), 
    .Y_i(y_w), 
    .Z_i(z_w), 
    .Data_Available_o(data_available_1_w), 
    .Data_o(data_w), 
    .Unused_bits_o(unused_bits_w)
    );
	 
uart_transmission IP_2 (                     // This IP is responsible to transmit the converted data on UART port
    .Clk_i(Clk_i), 
    .Reset_i(Reset_i), 
    .Data_Available_i(data_available_1_w), 
    .Data_i(data_w), 
    .Tx_o(tx_w)
    );
	 
assign Tx_o     = tx_w;
assign CS_o     = cs_w;
assign SCL_o    = scl_w;
assign Debug_o  = debug_w;                                           // This can be used to see the response from Slave Device during Ack or data read 
assign Unused_o = unused_bits_w;                                     // It can be ignored !!!
assign X_o = x_w;                                                    // It can be ignored !!!
assign Y_o = y_w;                                                    // It can be ignored !!!
assign Z_o = z_w;                                                    // It can be ignored !!! 
assign Data_Available_o = data_available_1_w || data_available_0_w;  // It can be ignored !!!

endmodule
