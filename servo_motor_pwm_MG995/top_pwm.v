////////////////////////////////////////////////////////////////////////////////
// Company: DIY Projects
// Engineer: Sarmad Wahab
//
// Create Date: 25.06.2021
// Design Name: PWM generation for DC Servo Motor MG995
// Module Name: top_pwm
// Target Device: Xilinx Spartan 6
// Tool versions: Design ISE 14.7
////////////////////////////////////////////////////////////////////////////////


module top_pwm
	(
		Clk_i,
		Reset_i,
		Sel_i,
		Pwm_o,
		Tx_o

);
parameter duty_cycle_length_p = 17;
parameter mux_sel_length_p    = 2;

input Clk_i, Reset_i;
input [mux_sel_length_p-1 : 0]     Sel_i;
output Pwm_o, Tx_o;

wire pwm_w;
wire available_w;
wire [duty_cycle_length_p-1 : 0] duty_cycle_w;
wire tx_w;



pwm_servo_motor IP_1 (           // This IP is generating PWM signal (0, 90, 180 angles or 0.5ms, 1.5ms, 2.5ms)
    .Clk_i(Clk_i), 
    .Reset_i(Reset_i), 
    .Sel_angle_i(Sel_i), 
    .Pwm_o(pwm_w)
    );
	 
pwm_monitor IP_2 (               // This IP is used to monitor the length of active duty cycle
    .Clk_i(Clk_i), 
    .Reset_i(Reset_i), 
    .Pwm_i(pwm_w), 
    .Sel_i(Sel_i),
    .Duty_Cycle_o(duty_cycle_w), 
    .Available_o(available_w)
    );	 
	 
pwm_uart IP_3 (                  // This IP prints outs length of active duty cycles monitored by IP_2 at serial port (use putty with 9600 baudrate)
    .Clk_i(Clk_i), 
    .Reset_i(Reset_i), 
    .Enable_i(available_w), 
    .Data_i(duty_cycle_w), 
    .Tx_o(tx_w)
    );	 

assign Tx_o  = tx_w; 
assign Pwm_o = pwm_w;

endmodule	 
