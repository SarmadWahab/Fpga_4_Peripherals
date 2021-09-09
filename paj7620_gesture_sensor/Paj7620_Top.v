`timescale 1ns / 1ps
`include "give_your_local_location\paj7620_parameters.v"
//////////////////////////////////////////////////////////////////////////////////
// Company:        DIY Projects 
// Engineer:       Sarmad Wahab 
// Create Date:    20:09:23 09/04/2021 
// Design Name:    Paj7620
// Module Name:    Paj7620_Top 
// Target Devices: Xilinx Spartan 6 
// Tool versions:  Design ISE 14.7
//////////////////////////////////////////////////////////////////////////////////
module Paj7620_Top(
	Clk_i,
	Reset_i,
	Switch_i,
	Int_i,
	SDA_io,
	SCL_o,
	Tx_o,
	Unused_bit_o
    );

input  Clk_i,Reset_i,Switch_i,Int_i;
inout  SDA_io;
output SCL_o, Tx_o,Unused_bit_o;


wire scl_w;
wire tx_w;


wire [7:0] gesture_w;
wire       data_available_w;
wire       debug_w;

i2c_controller IP_1 (                    // This IP is responsible for configuring and communicating with Paj7620
    .Clk_i(Clk_i), 
    .Reset_i(Reset_i), 
    .Switch_i(Switch_i), 
    .Int_i(Int_i), 
    .SDA_io(SDA_io), 
    .SCL_o(scl_w), 
    .Gesture_o(gesture_w), 
    .Data_Available_o(data_available_w), 
    .Debug_o(debug_w)
    );
	 
Uart_Transmission IP_2 (                 // This IP send the gesture data to UART with baud rate 9600
    .Clk_i(Clk_i), 
    .Reset_i(Reset_i), 
    .Data_Available_i(data_available_w), 
    .Data_i(gesture_w), 
    .Tx_o(tx_w)
    );

assign SCL_o        = scl_w;
assign Tx_o         = tx_w;
assign Unused_bit_o = debug_w;

endmodule
