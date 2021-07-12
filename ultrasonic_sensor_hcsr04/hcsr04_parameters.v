`ifndef _hcsr04_parameters_h
`define _hcsr04_parameters_h
 
localparam high_p                              = 1;
localparam low_p                               = 0;
localparam distance_length_p                   = 43;
localparam uart_data_length_p                  = 8;
localparam data_length_p                       = 12;

localparam single_bit_p                        = 1'b1;
localparam ultrasonic_sensor_time_period_p     = 3000000;  // Time period of 60ms
localparam trigger_duty_clock_cycles_p         = 500;      // duty cycle of 10us
localparam ultrasonic_sensor_trigger_counter_p = 22;

localparam echo_duty_cycle_counter_r           = 21;
localparam in_cm_p                             = 58000;    // in cm 
localparam in_inches_p                         = 148000;   // in inches
localparam all_bits_one_p                      = 8'hFF;
localparam to_nanoseconds_p                    = 3'd5;     // counter 2 * 2 * 5 in nano seconds
localparam multiply_by_4_p                     = 2'd2;     // counter 2 * 2 * 5 in nano seconds

localparam fsm_state_length_p                  = 3;
localparam fsm_idle_p                          = 0;
localparam fsm_distance_in_cm_or_inches_p      = 1;
localparam fsm_mod_data_p                      = 2;
localparam fsm_to_ascii_p                      = 3;
localparam fsm_divide_data_p                   = 4;
localparam fsm_end_p                           = 5;
localparam ultrasonic_sensor_data_length_p     = 13;
localparam divide_ip_latency_0                 = 30;
localparam divide_ip_latency_1                 = 18;
localparam numeber_of_division_stages          = 3;        // As the maximum value we can get from sensor is 400cm so 3 stages are enough !!!
localparam mod_by_10_p                         = 4'd10;
localparam div_ip_data_length_p                = 8;

localparam baud_rate_p        	               = 5208;     // Baud rate 9600 for uart
localparam uart_max_frame_p   	               = 64;
localparam ascii_prefix        	               = 4'h3;
localparam cr_lf_p            	               = 16'h0A0D;
localparam cm_p               	               = 16'h6D63;
localparam in_p               	               = 16'h6E69;
localparam space_p            	               = 8'h20;
localparam unit_size_p        	               = 16;
localparam fsm_uart_idle_p    	               = 0;
localparam fsm_uart_start_p         	       = 1;
localparam fsm_uart_transmit_data_p 	       = 2;
localparam fsm_uart_stop_p          	       = 3;
localparam some_bits_one_p     	               = 16'h939E;


`endif
