
`ifndef _mg33_parameters_h
`define _mg33_parameters_h

localparam high_p                  = 1;
localparam low_p                   = 0;
localparam single_bit_p            = 1'b1;
localparam mux_selector_length_p   = 2;
localparam pwm_counter_length_p    = 19;
localparam pwm_counter_limit_p     = 500000;     //100hz Frequency for PWM signal (
localparam pwm_0_duty_cycle_p      = 0;          // 0  % duty cycle
localparam pwm_14_duty_cycle_p     = 70000;      // 14 % duty cycle
localparam pwm_25_duty_cycle_p     = 125000;     // 25 % duty cycle
localparam pwm_100_duty_cycle_p    = 500000;     // 100% duty cycle 
localparam all_bits_one_p          = 19'h7FFFF;  // To avoid optimizing register warnings (it can be omitted)

`endif
