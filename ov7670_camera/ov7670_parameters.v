`ifndef _Ov7670_parameters_h
`define _Ov7670_parameters_h
  
  
  parameter high_p                            = 1'b1;
  parameter low_p                             = 1'b0;
  parameter zero_p                            = 0;
  parameter slave_address_p                   = 8'h42;
  
  parameter fsm_allow_memory_p                = 1'd0;
  parameter fsm_dont_allow_memory_p           = 1'd1;
 
  parameter sccb_clock_counter_length_p       = 3'd7;
  parameter sccb_max_counter_value_p          = 8'd80;  // 80 using 24 Mhz clock 
  parameter sccb_fsm_length_p                 = 2'd2;
  parameter sccb_internal_counter_length_p    = 4'hE;
  parameter sccb_internal_counter_max_value_p = 3'd7;   // 0 - 7 makes 8 cycles
  parameter sccb_total_reg_number_p           = 8'd61;
  parameter sccb_settling_reset_time_p        = 15'd24004;
  parameter sccb_global_wait_counter_length_p = 8'd24;
  parameter sccb_one_second_p                 = 25'd24003841;
  
  parameter sccb_fsm_idle_p                   = 3'd0;
  parameter sccb_fsm_start_p                  = 3'd1;
  parameter sccb_fsm_slave_address_p          = 3'd2;
  parameter sccb_fsm_dont_care_p              = 3'd3;
  parameter sccb_fsm_reg_address_p            = 3'd4;
  parameter sccb_fsm_write_data_p             = 3'd5;
  parameter sccb_fsm_stop_p                   = 3'd6;
  
  
  
  parameter pixel_counter_line_counter_length_p = 4'd8;
  parameter pixel_gen_back_porch                = 5'd16; // 17 lines
  parameter pixel_gen_fsm_idle_p                = 2'd0;
  parameter pixel_gen_fsm_first_byte_p          = 2'd1;
  parameter pixel_gen_fsm_second_byte_p         = 2'd2;
  parameter pixel_gen_fsm_stop_p                = 2'd3;
  parameter pixel_gen_fsm_length_p              = 1;
  parameter number_of_pixels_in_row_p           = 10'd640; // 640 pixels
  parameter number_of_lines_p                   = 9'd479;  // 480 lines
  parameter data_length_p                       = 3'd7;
  parameter pixel_counter_length_p              = 4'd9;
  parameter pixel_length_p                      = 4'hF;
  
  
  parameter memory_buffer_pixel_counter_length_p = 1'b1;
  parameter memory_buffer_address_length_p       = 4'd14;
  parameter memory_buffer_data_length_p          = 4'hF;
  parameter pixel_in_one_frame_p                 = 15'd18400;  // 160x120
  parameter total_possible_pixels_p              = 15'd32767;
  
  parameter rd_addr_fsm_idle_p                   = 1'd0;
  parameter rd_addr_fsm_extract_frame_data_p     = 1'd1;
  
  parameter vga_fsm_idle_p                       = 2'd0;
  parameter vga_fsm_video_p                      = 2'd1;
  parameter vga_fsm_frame_completed_p            = 2'd2;
  parameter vga_total_pixel_p                    = 11'd800;
  parameter vga_total_lines_p                    = 10'd524;
  parameter vga_pixel_counter_length_p           = 4'hA;
  parameter vga_line_counter_length_p            = 4'h9;
  parameter vga_hsync_sync_p                     = 8'd96;
  parameter vga_vsync_sync_p                     = 3'd2;
  parameter vga_rgb_length_p                     = 2'd3;
  parameter left_border_p                        = 8'd143;  
  parameter right_border_p                       = 9'd303;
  parameter up_border_p                          = 5'd32;
  parameter down_border_p                        = 8'd147;
  `endif