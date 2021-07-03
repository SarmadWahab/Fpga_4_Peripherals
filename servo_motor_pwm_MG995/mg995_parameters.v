`ifndef _mg995_parameters_h
`define _mg995_parameters_h

localparam single_bit_p                = 1'b1;
localparam high_p                      = 1; 
localparam low_p                       = 0;
localparam stable_clock_cycles_p       = 7;         // 8 clock cycles to check whether input signal is stable or not
localparam pwm_clock_cycles_p          = 1000000;   // Clock cycles for pwm signal   using 50Mhz (20ms)
localparam pwm_counter_length_p        = 20;        // Counter length for pwm signal using 50Mhz (20ms)
localparam angle_0_clock_cycles_p      = 25000;     // Clock cycles for pwm signal   using 50Mhz (0.5ms or 0   angle)
localparam angle_90_clock_cycles_p     = 75000;     // Clock cycles for pwm signal   using 50Mhz (1.5ms or 90  angle)
localparam angle_180_clock_cycles_p    = 125000;    // Clock cycles for pwm signal   using 50Mhz (2.5ms or 180 angle)
localparam mux_sel_length_p            = 2;
localparam all_bits_one_p              = 17'h1FFFF; // This is used to bypass the optimizing warnings !!! (it can be omitted)
localparam duty_cycle_counter_length_p = 17;
localparam some_bits_one_p             = 17'h01208; //This parameter is used to ignore optimizng warnings (it can be omitted)
localparam data_length_p               = 17;
localparam uart_max_frame_p            = 40;
localparam uart_data_length_p          = 8;
localparam baud_rate_p                 = 5208;            // Using 50 Mhz for 9600 baud rate (50 x 1000000/9600  = 5208)
localparam idle_p                      = 2'b00, start_p = 2'b01, transmit_data_p = 2'b10, stop_p = 2'b11;
localparam size_p                      = 2;
localparam angle_0_hex_code_p          = 40'h0C50B00000;  // 0   + CR + LF => whenever angle 0 or 0.5ms configuration is selected 0 will be printed via Uart Port
localparam angle_90_hex_code_p         = 40'h9C0C50b000;  // 90  + CR + LF => whenever angle 90 or 1.5ms configuration is selected 90 will be printed via Uart Port
localparam angle_180_hex_code_p        = 40'h8C1C0C50B0;  // 180 + CR + LF => whenever angle 180 or 2.5ms configuration is selected 180 will be printed via Uart Port

`endif
