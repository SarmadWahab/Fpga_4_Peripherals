`ifndef _paj7620_parameters_h
`define _paj7620_parameters_h

  parameter high_p                            = 1'b1;
  parameter low_p                             = 1'b0;
  parameter zero_p                            = 0;
  parameter one_p                             = 1;
  parameter fsm_idle_p                        = 2'b00;
  parameter fsm_wait_p                        = 2'b01;
  parameter fsm_activate_p                    = 2'b10;
  parameter stop_time_p                       = 10'd750; 
  parameter offset_p                          = 10'hF;
  parameter i2c_duty_cycle_counter_length_p   = 4'd9;
  parameter characteristics_mantissa_length_p = 6'd32;
  parameter eight_clock_cycles_p              = 4'd8;
  
  parameter stabilization_time_p              = 16'd35000;
  parameter i2c_fsm_idle_p                    = 3'd0;
  parameter i2c_fsm_start_p                   = 3'd1;
  parameter i2c_fsm_slave_address_p           = 3'd2;      // Read/Write bit included !!! 
  parameter i2c_fsm_slave_ack_p               = 3'd3;
  parameter i2c_fsm_reg_address_p             = 3'd4;
  parameter i2c_fsm_repeated_start_p          = 3'd5;
  parameter i2c_fsm_data_to_read_p            = 3'd6;
  parameter i2c_time_period                   = 10'd1000;  //100Khz
  parameter positive_edge_p                   = 9'd325;
  parameter all_ones_p                        = 11'h7FF;
  parameter i2c_fsm_state_length_p            = 2'd2;
 
  parameter i2c_fsm_data_to_write_p           = 3'd5;

  parameter registers_to_write_p              = 51;         // How many times single read should be executed
  parameter number_of_axes_p                  = 3'd1;      
  parameter data_length_p                     = 5'h10;
  parameter delay_p                           = 5'd20;
  
  parameter single_bit_p                      = 1'b1;
  parameter ascii_prefix_p                    = 4'h03;
  parameter lf_p                              = 8'h0A;
  parameter cr_p                              = 8'h0D;
  parameter uart_data_length_p 		          = 8;
  parameter uart_frames_p      		          = 15;
  parameter baud_rate_p        		          = 5208;
  parameter fsm_uart_idle_p   		          = 2'd0;
  parameter fsm_uart_start_p                  = 2'd1;
  parameter fsm_uart_transmit_data_p          = 2'd2;
  parameter fsm_uart_stop_p                   = 2'd3;
  parameter uart_baud_rate_length_p           = 4'hC;
  parameter uart_data_frame_length_p          = 8'd119;
  parameter uart_frame_counter_p              = 3'd4;
  
  
 



`endif