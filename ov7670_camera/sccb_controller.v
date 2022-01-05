`timescale 1ns / 1ps
`include "give_your_local_location\ov7670_parameters.v"
//////////////////////////////////////////////////////////////////////////////////
// Company:        DIY Projects 
// Engineer:       Sarmad Wahab 
// Create Date:    21:13:03 01/04/2022
// Design Name:    Ov7670 
// Module Name:    sccb_controller  
// Target Devices: Xilinx Spartan 6 
// Tool versions:  Design ISE 14.7
//////////////////////////////////////////////////////////////////////////////////
module sccb_controller(
    input Clk_i,
    input Reset_i,
    input Switch_i,
    output SCL_o,
    inout SDA_io,
    output Config_Done_o
    );
	 

   reg 	   start_sclk_r;
   reg 	   sccb_clk_r;
   reg 	   sccb_clk_delay_r;
   reg 	   sccb_clk_fall_edge_r;
   reg 	   sccb_clk_rise_edge_r;
   reg 	   sccb_sda_r;
   reg 	   sccb_frame_completed_r;
   reg 	   config_done_r;

   reg [sccb_clock_counter_length_p       : 0] sccb_counter_r;
   reg [sccb_fsm_length_p                 : 0] next_state_r;
   reg [sccb_fsm_length_p                 : 0] previous_state_r;
   reg [sccb_internal_counter_length_p    : 0] sccb_internal_counter_r;
   reg [sccb_clock_counter_length_p       : 0] reg_address_r;
   reg [sccb_clock_counter_length_p       : 0] reg_data_r;
   reg [sccb_clock_counter_length_p       : 0] reg_number_r;
   reg [sccb_global_wait_counter_length_p : 0] global_wait_r;



   always @ (posedge Clk_i or negedge Reset_i)
     begin
	if(Reset_i == low_p)
	  begin
	     global_wait_r <= zero_p;
	  end
	else
	  begin
	     if(Switch_i == high_p && global_wait_r < sccb_one_second_p)
	       begin
		  global_wait_r <= global_wait_r + high_p;
	       end
	     else
	       begin
		  global_wait_r <= global_wait_r;
	       end
	  end
     end



   always @ (posedge Clk_i or negedge Reset_i)  // This block is responsible to count number of registers for Configuration
     begin
	if (Reset_i == low_p)
	  begin
	     reg_number_r <= zero_p;
	  end
	else
	  begin
	     if(sccb_frame_completed_r == high_p && reg_number_r < sccb_total_reg_number_p)
	       begin
		  reg_number_r <= reg_number_r + high_p;
	       end
	     else
	       begin
		  reg_number_r <= reg_number_r;
	       end
	  end
     end
	
   always @ (posedge Clk_i or negedge Reset_i)  //This block is used to configure the Camera !!!
     begin
	if(Reset_i == low_p)
	  begin
	     reg_address_r <= zero_p;
	     reg_data_r    <= zero_p;
	  end
	else
	  begin
	     case(reg_number_r)
	       0:
		 begin
		    reg_address_r <= 8'h12;
		    reg_data_r    <= 8'h80;
		 end
	       1:
		 begin
		    reg_address_r <= 8'h12;
		    reg_data_r    <= 8'h80;
		 end
	       2:
		 begin
		    reg_address_r <= 8'h12;
		    reg_data_r    <= 8'h04;
		 end
	       3:
		 begin
		    reg_address_r <= 8'h11;
		    reg_data_r    <= 8'h00;
		 end
	       4:
		 begin
		    reg_address_r <= 8'h0C;
		    reg_data_r    <= 8'h00;
		 end
	       5:
		 begin
		    reg_address_r <= 8'h3E;
		    reg_data_r    <= 8'h00;
		 end
	       6:
		 begin
		    reg_address_r <= 8'h8C;
		    reg_data_r    <= 8'h00;
		 end
	       7:
		 begin
		    reg_address_r <= 8'h04;
		    reg_data_r    <= 8'h00;
		 end
	       8:
		 begin
		    reg_address_r <= 8'h40;
		    reg_data_r    <= 8'hD0;
		 end
	       9:
		 begin
		    reg_address_r <= 8'h3A;
		    reg_data_r    <= 8'h04;
		 end
	       10:
		 begin
		    reg_address_r <= 8'h14;
		    reg_data_r    <= 8'h38;
		 end
	       11:
		 begin
		    reg_address_r <= 8'h4f;
		    reg_data_r    <= 8'hB3;
		 end
	       12:
		 begin
		    reg_address_r <= 8'h50;
		    reg_data_r    <= 8'hb3;
		 end
	       13:
		 begin
		    reg_address_r <= 8'h51;
		    reg_data_r    <= 8'h00;
		 end
	       14:
		 begin
		    reg_address_r <= 8'h52;
		    reg_data_r    <= 8'h3D;
		 end
	       15:
		 begin
		    reg_address_r <= 8'h53;
		    reg_data_r    <= 8'ha7;
		 end
	       16:
		 begin
		    reg_address_r <= 8'h54;
		    reg_data_r    <= 8'he4;
		 end
	       17:
		 begin
		    reg_address_r <= 8'h58;
		    reg_data_r    <= 8'h9E;
		 end
	       18:
		 begin
		    reg_address_r <= 8'h3D;
		    reg_data_r    <= 8'hC0;
		 end
	       19:
		 begin
		    reg_address_r <= 8'h11;
		    reg_data_r    <= 8'h00;
		 end
	       20:
		 begin
		    reg_address_r <= 8'h17;
		    reg_data_r    <= 8'h11;
		 end
	       21:
		 begin	
		    reg_address_r <= 8'h18;
		    reg_data_r    <= 8'h61;
		 end
	       22:
		 begin
		    reg_address_r <= 8'h32;
		    reg_data_r    <= 8'hA4;
		 end
	       23:
		 begin
		    reg_address_r <= 8'h19;
		    reg_data_r    <= 8'h03;
		 end
	       24:
		 begin
		    reg_address_r <= 8'h1A;
		    reg_data_r    <= 8'h7B;
		 end
	       25:
		 begin
		    reg_address_r <= 8'h03;
		    reg_data_r    <= 8'h0A;
		 end
	       26:
		 begin
		    reg_address_r <= 8'h0E;
		    reg_data_r    <= 8'h61;
		 end
	       27:
		 begin
		    reg_address_r <= 8'h0F;
		    reg_data_r    <= 8'h4B;
		 end
	       28:
		 begin
		    reg_address_r <= 8'h16;
		    reg_data_r    <= 8'h02;
		 end
	       29:
		 begin
		    reg_address_r <= 8'h1E;
		    reg_data_r    <= 8'h37;
		 end
	       30:
		 begin
		    reg_address_r <= 8'h21;
		    reg_data_r    <= 8'h02;
		 end
	       31:
		 begin
		    reg_address_r <= 8'h22;
		    reg_data_r    <= 8'h91;
		 end
	       32:
		 begin
		    reg_address_r <= 8'h29;
		    reg_data_r    <= 8'h07;
		 end
	       33:
		 begin
		    reg_address_r <= 8'h33;
		    reg_data_r    <= 8'h0B;
		 end
	       34:
		 begin
		    reg_address_r <= 8'h37;
		    reg_data_r    <= 8'h1D;
		 end
	       35:
		 begin
		    reg_address_r <= 8'h38;
		    reg_data_r    <= 8'h71;
		 end
	       36:
		 begin
		    reg_address_r <= 8'h39;
		    reg_data_r    <= 8'h2A;
		 end
	       37:
		 begin
		    reg_address_r <= 8'h3C;
		    reg_data_r    <= 8'h78;
		 end
	       38:
		 begin
		    reg_address_r <= 8'h4D;
		    reg_data_r    <= 8'h40;
		 end
	       39:
		 begin
		    reg_address_r <= 8'h4E;
		    reg_data_r    <= 8'h20;
		 end
	       40:
		 begin
		    reg_address_r <= 8'h69;
		    reg_data_r    <= 8'h00;
		 end
	       41:
		 begin
		    reg_address_r <= 8'h6B;
		    reg_data_r    <= 8'h8A;
		 end
	       42:
		 begin
		    reg_address_r <= 8'h74;
		    reg_data_r    <= 8'h10;
		 end
	       43:
		 begin
		    reg_address_r <= 8'h8D;
		    reg_data_r    <= 8'h4F;
		 end
	       44:
		 begin
		    reg_address_r <= 8'h8E;
		    reg_data_r    <= 8'h00;
		 end
	       45:
		 begin
		    reg_address_r <= 8'h8F;
		    reg_data_r    <= 8'h00;
		 end
	       46:
		 begin
		    reg_address_r <= 8'h90;
		    reg_data_r    <= 8'h00;
		 end
	       47:
		 begin
		    reg_address_r <= 8'h91;
		    reg_data_r    <= 8'h00;
		 end
	       48:
		 begin
		    reg_address_r <= 8'h96;
		    reg_data_r    <= 8'h00;
		 end
	       49:
		 begin
		    reg_address_r <= 8'h9A;
		    reg_data_r    <= 8'h00;
		 end
	       50:
		 begin
		    reg_address_r <= 8'hB0;
		    reg_data_r    <= 8'h84;
		 end
	       51:
		 begin
		    reg_address_r <= 8'hB1;
		    reg_data_r    <= 8'h0C;
		 end
	       52:
		 begin
		    reg_address_r <= 8'hB2;
		    reg_data_r    <= 8'h0E;
		 end
	       53:
		 begin
		    reg_address_r <= 8'hB3;
		    reg_data_r    <= 8'h82;
		 end
	       54:
		 begin
		    reg_address_r <= 8'hB8;
		    reg_data_r    <= 8'h0A;
		 end
	       55:
		 begin
		    reg_address_r <= 8'h35;
		    reg_data_r    <= 8'h0b;
		 end
	       56:
		 begin	
		    reg_address_r <= 8'h70;
		    reg_data_r    <= 8'h3A;
		 end
	       57:
		 begin	

		    reg_address_r <= 8'h71;
		    reg_data_r    <= 8'h35;
		 end
	       58:
		 begin	
		    reg_address_r <= 8'h72;
		    reg_data_r    <= 8'h11;
		 end
	       59:
		 begin	
		    reg_address_r <= 8'h73;
		    reg_data_r    <= 8'hF0;
		 end
	       60:
		 begin	
		    reg_address_r <= 8'hA2;
		    reg_data_r    <= 8'h02;
		 end
	       61:
		 begin	
		    reg_address_r <= 8'h15;
		    reg_data_r    <= 8'h00;
		 end

	       default:
		 begin
		    reg_address_r <= zero_p;
		    reg_data_r    <= zero_p;
		 end
	     endcase;
	  end
     end

   always @ (posedge Clk_i or negedge Reset_i)  // This block assert signal whenever configuration is done
     begin
	if(Reset_i == low_p)
	  begin
	     config_done_r <= low_p;
	  end
	else
	  begin
	     if(next_state_r == sccb_fsm_stop_p && reg_number_r == sccb_total_reg_number_p)
	       begin
		  config_done_r <= high_p;
	       end
	     else
	       begin
		  config_done_r <= config_done_r;
	       end
	  end
     end

   always @ (posedge Clk_i or negedge Reset_i) // This block is responsible count till timeperiod of 3.0us
     begin
	if(Reset_i == low_p)
	  begin
	     sccb_counter_r <= zero_p;
	  end
	else
	  begin
	     if(start_sclk_r == high_p && sccb_counter_r < sccb_max_counter_value_p)
	       begin
		  sccb_counter_r <= sccb_counter_r + high_p;
	       end
	     else
	       begin
		  sccb_counter_r <= zero_p;
	       end
	  end
     end

   always @ (posedge Clk_i or negedge Reset_i)  // This block is responsible to generate the sclk for sccb interface
     begin
	if(Reset_i == low_p)
	  begin
	     sccb_clk_r <= high_p;
	  end
	else
	  begin
	     if(sccb_counter_r < (sccb_max_counter_value_p >> high_p))
	       begin
		  sccb_clk_r <= high_p;
	       end
	     else
	       begin
		  sccb_clk_r <= low_p;
	       end
	  end
     end
   
   always @ (posedge Clk_i or negedge Reset_i)  // This block is used to delay clock signal by one clock cycle
     begin
	if(Reset_i == low_p)
	  begin
	     sccb_clk_delay_r <= low_p;
	  end
	else
	  begin
	     sccb_clk_delay_r <= sccb_clk_r;
	  end
     end
	
   always @ (posedge Clk_i or negedge Reset_i)  // This block flags rise and fall edge of clock 
     begin
	if(Reset_i == low_p)
	  begin
	     sccb_clk_fall_edge_r <= low_p;
	     sccb_clk_rise_edge_r <= low_p;
	  end
	else
	  begin
	     if(sccb_clk_r == low_p && sccb_clk_delay_r == high_p)
	       begin
		  sccb_clk_fall_edge_r <= high_p;
		  sccb_clk_rise_edge_r <= low_p;
	       end
	     else if (sccb_clk_r == high_p && sccb_clk_delay_r == low_p)
	       begin
		  sccb_clk_fall_edge_r <= low_p;
		  sccb_clk_rise_edge_r <= high_p;
	       end
	     else
	       begin
		  sccb_clk_fall_edge_r <= low_p;
		  sccb_clk_rise_edge_r <= sccb_clk_rise_edge_r;
	       end
	  end
     end

   always @ (posedge Clk_i or negedge Reset_i)  // FSM for sccb interface
     begin
	if(Reset_i == low_p)
	  begin
	     next_state_r    			<= sccb_fsm_idle_p;
	     previous_state_r 			<= sccb_fsm_idle_p;
	     start_sclk_r     			<= low_p;
	     sccb_sda_r       			<= high_p;
	     sccb_internal_counter_r <= zero_p;
	     sccb_frame_completed_r  <= low_p;
	  end
	else
	  begin
	     case(next_state_r)
	       sccb_fsm_idle_p:
		 begin
		    if(Switch_i == high_p && global_wait_r == sccb_one_second_p)
		      begin
			 next_state_r <= sccb_fsm_start_p;
			 start_sclk_r <= high_p;
			 sccb_sda_r   <= low_p;
		      end
		    else
		      begin
			 next_state_r <= sccb_fsm_idle_p;
			 start_sclk_r <= low_p;
			 sccb_sda_r   <= high_p;
		      end
		    previous_state_r        <= sccb_fsm_idle_p;
		    sccb_internal_counter_r <= zero_p;
		    sccb_frame_completed_r  <= low_p;
		 end
	       sccb_fsm_start_p:
		 begin
		    if(sccb_clk_fall_edge_r == high_p)
		      begin
			 next_state_r     <= sccb_fsm_slave_address_p;
			 previous_state_r <= sccb_fsm_start_p;
			 sccb_sda_r       <= slave_address_p[sccb_clock_counter_length_p - sccb_internal_counter_r];
		      end
		    else
		      begin
			 next_state_r     <= next_state_r;
			 previous_state_r <= previous_state_r;
			 sccb_sda_r       <= sccb_sda_r;
		      end
		    start_sclk_r            <= start_sclk_r;
		    sccb_internal_counter_r <= sccb_internal_counter_r;
		    sccb_frame_completed_r  <= sccb_frame_completed_r;
		 end
	       sccb_fsm_slave_address_p:
		 begin
		    if(sccb_clk_fall_edge_r == high_p && sccb_internal_counter_r == sccb_internal_counter_max_value_p)
		      begin
			 next_state_r     			<= sccb_fsm_dont_care_p;
			 previous_state_r 			<= sccb_fsm_slave_address_p;
			 sccb_sda_r       			<= sccb_sda_r;
			 sccb_internal_counter_r <= zero_p;
		      end
		    else if (sccb_clk_fall_edge_r == high_p && sccb_internal_counter_r < sccb_internal_counter_max_value_p)
		      begin
			 next_state_r     			<= next_state_r;
			 previous_state_r 			<= previous_state_r;
			 sccb_sda_r       			<= sccb_sda_r;
			 sccb_internal_counter_r                <= sccb_internal_counter_r + high_p;
		      end
		    else
		      begin
			 next_state_r     			<= next_state_r;
			 previous_state_r 			<= previous_state_r;
			 sccb_internal_counter_r                <= sccb_internal_counter_r;
			 sccb_sda_r       			<= slave_address_p[sccb_clock_counter_length_p - sccb_internal_counter_r];
		      end
		    start_sclk_r			  <= start_sclk_r;
		    sccb_frame_completed_r <= sccb_frame_completed_r;
		 end
	       sccb_fsm_dont_care_p:
		 begin
		    if(sccb_clk_fall_edge_r == high_p && previous_state_r == sccb_fsm_slave_address_p)
		      begin
			 next_state_r <= sccb_fsm_reg_address_p;
			 sccb_sda_r   <= reg_address_r[sccb_clock_counter_length_p - sccb_internal_counter_r];
		      end
		    else if (sccb_clk_fall_edge_r == high_p && previous_state_r == sccb_fsm_reg_address_p)
		      begin
			 next_state_r <= sccb_fsm_write_data_p;
			 sccb_sda_r   <= reg_data_r[sccb_clock_counter_length_p - sccb_internal_counter_r];
		      end
		    else if (sccb_clk_fall_edge_r == high_p && previous_state_r == sccb_fsm_write_data_p)
		      begin
			 next_state_r <= sccb_fsm_stop_p;
			 sccb_sda_r   <= low_p;
		      end
		    else
		      begin
			 next_state_r <= next_state_r;
			 sccb_sda_r   <= sccb_sda_r;
		      end
		    previous_state_r 			<= previous_state_r;
		    start_sclk_r     			<= start_sclk_r;
		    sccb_internal_counter_r             <= sccb_internal_counter_r;
		    sccb_frame_completed_r              <= sccb_frame_completed_r;
		 end
	       sccb_fsm_reg_address_p:
		 begin
		    if(sccb_clk_fall_edge_r == high_p && sccb_internal_counter_r == sccb_internal_counter_max_value_p)
		      begin
			 next_state_r     			<= sccb_fsm_dont_care_p;
			 previous_state_r 			<= sccb_fsm_reg_address_p;
			 sccb_sda_r       			<= sccb_sda_r;
			 sccb_internal_counter_r                <= zero_p;
		      end
		    else if (sccb_clk_fall_edge_r == high_p && sccb_internal_counter_r < sccb_internal_counter_max_value_p)
		      begin
			 next_state_r     			<= next_state_r;
			 previous_state_r 			<= previous_state_r;
			 sccb_sda_r                             <= sccb_sda_r;
			 sccb_internal_counter_r                <= sccb_internal_counter_r + high_p;
		      end
		    else
		      begin
			 next_state_r     			<= next_state_r;
			 previous_state_r 			<= previous_state_r;
			 sccb_sda_r       			<= reg_address_r[sccb_clock_counter_length_p - sccb_internal_counter_r];
			 sccb_internal_counter_r                <= sccb_internal_counter_r;
		      end
		    start_sclk_r 			        <= start_sclk_r;
		    sccb_frame_completed_r                      <= sccb_frame_completed_r;
		 end
	       sccb_fsm_write_data_p:
		 begin
		    if(sccb_clk_fall_edge_r == high_p && sccb_internal_counter_r == sccb_internal_counter_max_value_p)
		      begin
			 next_state_r     			<= sccb_fsm_dont_care_p;
			 previous_state_r 			<= sccb_fsm_write_data_p;
			 sccb_sda_r       			<= sccb_sda_r;
			 sccb_internal_counter_r <= zero_p;
		      end
		    else if (sccb_clk_fall_edge_r == high_p && sccb_internal_counter_r < sccb_internal_counter_max_value_p)
		      begin
			 next_state_r     			<= next_state_r;
			 previous_state_r 			<= previous_state_r;
			 sccb_sda_r       			<= sccb_sda_r;
			 sccb_internal_counter_r <= sccb_internal_counter_r + high_p;
		      end
		    else
		      begin
			 next_state_r     			<= next_state_r;
			 previous_state_r 			<= previous_state_r;
			 sccb_internal_counter_r <= sccb_internal_counter_r;
			 sccb_sda_r      			<= reg_data_r[sccb_clock_counter_length_p - sccb_internal_counter_r];
		      end
		    start_sclk_r           <= start_sclk_r;
		    sccb_frame_completed_r <= sccb_frame_completed_r;
		 end
	       sccb_fsm_stop_p:
		 begin
		    if(sccb_clk_rise_edge_r == high_p && sccb_counter_r == ((sccb_max_counter_value_p >> high_p) - high_p - high_p) && sccb_sda_r == low_p) // Make SDA high
		      begin
			 next_state_r 			   <= next_state_r;
			 start_sclk_r            <= low_p;
			 sccb_sda_r   			   <= high_p;
			 sccb_frame_completed_r  <= sccb_frame_completed_r;
			 sccb_internal_counter_r <= sccb_internal_counter_r;
		      end
		    else
		      begin
			 if(sccb_internal_counter_r == sccb_settling_reset_time_p && sccb_sda_r == high_p && reg_number_r < sccb_total_reg_number_p)
			   begin
			      next_state_r 			   <= sccb_fsm_idle_p;
			      start_sclk_r 			   <= low_p;
			      sccb_sda_r   			   <= sccb_sda_r;
			      sccb_frame_completed_r  <= high_p;
			      sccb_internal_counter_r <= zero_p;
			   end
			 else if (sccb_internal_counter_r == sccb_settling_reset_time_p && sccb_sda_r == high_p && reg_number_r < sccb_total_reg_number_p)
			   begin
			      next_state_r 			   <= next_state_r;
			      start_sclk_r 			   <= low_p;
			      sccb_sda_r   			   <= sccb_sda_r;
			      sccb_frame_completed_r  <= sccb_frame_completed_r;
			      sccb_internal_counter_r <= zero_p;
			   end
			 else
			   begin
			      next_state_r 			   <= next_state_r;
			      start_sclk_r 			  <= start_sclk_r;
			      sccb_sda_r   			   <= sccb_sda_r;
			      sccb_frame_completed_r  <= sccb_frame_completed_r;
			      sccb_internal_counter_r <= sccb_internal_counter_r + sccb_sda_r;
			   end
		      end
		    previous_state_r 			<= previous_state_r;
		    
		 end
	       default:
		 begin
		    next_state_r    			<= sccb_fsm_idle_p;
		    previous_state_r 			<= sccb_fsm_idle_p;
		    start_sclk_r     			<= low_p;
		    sccb_sda_r       			<= low_p;
		    sccb_internal_counter_r <= zero_p;
		    sccb_frame_completed_r  <= low_p;
		 end
	     endcase;
	  end
     end


assign SCL_o         = sccb_clk_r;
assign SDA_io        = sccb_sda_r ? 1'bz : low_p; 
assign Config_Done_o = config_done_r;

endmodule
