`ifndef _Tmp_LDR_parameters_h
`define _Tmp_LDR_parameters_h
  
  
parameter high_p                     = 1'b1;
parameter low_p                      = 1'b0;
parameter zero_p                     = 0;
parameter one_p                      = 1;

parameter data_length_for_IP_0       = 4'hB;
parameter data_length_for_IP_1       = 4'hF;

parameter spi_fsm_idle_p             = 3'd0; 
parameter spi_fsm_start_p            = 3'd1;
parameter spi_fsm_channel_p          = 3'd2;
parameter spi_fsm_read_data_p        = 3'd3;
parameter spi_fsm_stop_p             = 3'd4;
parameter spi_counter_length_p       = 2'd3;
parameter spi_timer_period_counter_p = 4'd9;
parameter spi_time_period_p          = 9'd500;  //1000ns or 1Mhz
parameter spi_time_period_half_p     = 9'd250;
parameter freeze_time_p              = 10'd1000;
parameter spi_internal_counter_p     = 4'hB;


parameter fsm_length_p               = 2'd2;
parameter fsm_idle_p                 = 3'd0;
parameter fsm_divide_by_1023_p       = 3'd1;
parameter fsm_multiply_by_500_p      = 3'd2;
parameter fsm_mod_10_p               = 3'd3;
parameter fsm_stop_p                 = 3'd4;
parameter divisor_1023_p             = 13'd4096;
parameter divisor_10_p               = 4'hA;
parameter division_latency_p         = 5'd30;
parameter multiply_latency_p         = 4'hF;
parameter converted_data_length_p    = 4'hF;
parameter dividend_length_p          = 5'd20;
parameter divisor_length_p           = 4'hC;



parameter single_bit_p               = 1'b1;
parameter ascii_prefix_p             = 4'h3;
parameter lf_p                       = 8'h0A;
parameter cr_p                       = 8'h0D;
parameter space_p                    = 8'h20;
parameter null_p                     = 8'h00;
parameter temp_p                     = 8'h43;
parameter lux_p                      = 8'h4C;
parameter uart_data_length_p 	     = 8;
parameter uart_frames_p      	     = 8;
parameter baud_rate_p        	     = 5208;
parameter fsm_uart_idle_p   	     = 2'd0;
parameter fsm_uart_start_p           = 2'd1;
parameter fsm_uart_transmit_data_p   = 2'd2;
parameter fsm_uart_stop_p            = 2'd3;
parameter uart_baud_rate_length_p    = 4'hC;
parameter uart_data_frame_length_p   = 8'd63;
parameter uart_frame_counter_p       = 3'd4;
  `endif
