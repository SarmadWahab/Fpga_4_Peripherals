////////////////////////////////////////////////////////////////////////////////
// Company: DIY Projects
// Engineer: Sarmad Wahab
//
// Create Date: 01.07.2021
// Design Name: PWM generation for DC Motor MG33
// Module Name: pwm_top
// Target Device: Xilinx Spartan 6
// Tool versions: Design ISE 14.7
////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
`include "give_your_local_location\mg33_parameters.v"

module pwm_top(
    Clk_i,
    Reset_i,
    Sel_i,
    Pwm_o,
	 Dir_o
    );




input                       Clk_i, Reset_i;
input [mux_selector_length_p-1 : 0] Sel_i;
output                         Pwm_o,Dir_o;

wire pwm_w;


pwm_dc_motor IP_1 (
    .Clk_i(Clk_i), 
    .Reset_i(Reset_i), 
    .Sel_i(Sel_i), 
    .Pwm_o(pwm_w)
    );


assign Pwm_o = pwm_w;
assign Dir_o = high_p;

endmodule
