`timescale 1ns / 1ps
`include "give_your_local_location\paj7620_parameters.v"
//////////////////////////////////////////////////////////////////////////////////
// Company:        DIY Projects
// Engineer:       Sarmad Wahab
// 
// Create Date:    21:13:03 08/26/2021 
// Design Name:    Paj7620
// Module Name:    i2c_single_write 
// Target Devices: Xilinx Spartan 6
// Tool versions:  Design ISE 14.7
//////////////////////////////////////////////////////////////////////////////////
module i2c_single_write(
   Clk_i,
   Reset_i,
   Switch_i,
   SDA_io,
   SCL_o,
   Debug_o,
   Data_Available_o
    );

  
   parameter i2c_fsm_stop_p           = 3'd6;
   parameter slave_address_p          = 8'hE6;
   parameter wait_time_p              = 11'd1000;

   input  Clk_i,Reset_i,Switch_i;
   inout  SDA_io;
   output SCL_o,Debug_o,Data_Available_o;

   reg       sda_r;
   reg       scl_r;
   reg       scl_delay_r;
   reg       scl_fall_edge_r;
   reg       scl_active_region;
   reg       scl_start_r;
   reg       read_write_r;
   reg       sda_read_r;
   reg       data_available_r;
   reg       write_config_done_r;
   
  
   reg [i2c_fsm_state_length_p                      : 0] next_state_r;
   reg [i2c_fsm_state_length_p                      : 0] previous_state_r;
   reg [i2c_fsm_state_length_p                      : 0] i2c_clock_counter_r;
   reg [eight_clock_cycles_p+high_p                 : 0] i2c_duty_cycle_counter_r;
   reg [eight_clock_cycles_p-high_p                 : 0] slave_address_r;
   reg [eight_clock_cycles_p-high_p                 : 0] reg_address_r;
   reg [eight_clock_cycles_p-high_p                 : 0] reg_data_r;
   reg [eight_clock_cycles_p+i2c_fsm_state_length_p : 0] wait_counter_r;
   reg [eight_clock_cycles_p-high_p-high_p-high_p   : 0] single_read_frame_count_r;


   always @ (posedge Clk_i or negedge Reset_i)  //Slave address for device
     begin
	if(Reset_i == low_p)
	  begin
	     slave_address_r <= zero_p;
	  end
	else
	  begin
	     if(next_state_r != i2c_fsm_idle_p)
	       begin
		  slave_address_r <= slave_address_p;
	       end
	     else
	       begin
		  slave_address_r <= 8'hFF;
	       end
	  end
     end

   always @ (posedge Clk_i or negedge Reset_i)  // Config registers for Paj7620 sensors
     begin
	if(Reset_i == low_p)
	  begin
	     reg_address_r <= zero_p;
	     reg_data_r    <= 8'hFF;
	  end
	else
	  begin
	     case(single_read_frame_count_r)
	       0:
		 begin
		    reg_address_r <= 8'hEF;
		    reg_data_r    <= 8'h00;
		 end
	       1:
		 begin
		    reg_address_r <= 8'h37;
		    reg_data_r    <= 8'h07;
		 end
	       2:
		 begin
		    reg_address_r <= 8'h38;
		    reg_data_r    <= 8'h17;
		 end
	       3:
		 begin
		    reg_address_r <= 8'h39;
		    reg_data_r    <= 8'h06;
		 end
	       4:
		 begin
		    reg_address_r <= 8'h42;
		    reg_data_r    <= 8'h01;
		 end
	       5:
		 begin
		    reg_address_r <= 8'h46;
		    reg_data_r    <= 8'h2D;
		 end
	       6:
		 begin
		    reg_address_r <= 8'h47;
		    reg_data_r    <= 8'h0F;
		 end
	       7:
		 begin
		    reg_address_r <= 8'h48;
		    reg_data_r    <= 8'h3C;
		 end
	       8:
		 begin
		    reg_address_r <= 8'h49;
		    reg_data_r    <= 8'h00;
		 end
	       9:
		 begin
		    reg_address_r <= 8'h4A;
		    reg_data_r    <= 8'h1E;
		 end
	       10:
		 begin
		    reg_address_r <= 8'h4C;
		    reg_data_r    <= 8'h20;
		 end
	       11:
		 begin
		    reg_address_r <= 8'h51;
		    reg_data_r    <= 8'h10;
		 end
	       12:
		 begin
		    reg_address_r <= 8'h5E;
		    reg_data_r    <= 8'h10;
		 end
	       13:
		 begin
		    reg_address_r <= 8'h60;
		    reg_data_r    <= 8'h27;
		 end
	       14:
		 begin
		    reg_address_r <= 8'h80;
		    reg_data_r    <= 8'h42;
		 end
	       15:
		 begin
		    reg_address_r <= 8'h81;
		    reg_data_r    <= 8'h44;
		 end
	       16:
		 begin
		    reg_address_r <= 8'h82;
		    reg_data_r    <= 8'h04;
		 end
	       17:
		 begin
		    reg_address_r <= 8'h8B;
		    reg_data_r    <= 8'h01;
		 end
	       18:
		 begin
		    reg_address_r <= 8'h90;
		    reg_data_r    <= 8'h06;
		 end
	       19:
		 begin
		    reg_address_r <= 8'h95;
		    reg_data_r    <= 8'h0A;
		 end
	       20:
		 begin
		    reg_address_r <= 8'h96;
		    reg_data_r    <= 8'h0C;
		 end
	       21:
		 begin
		    reg_address_r <= 8'h97;
		    reg_data_r    <= 8'h05;
		 end
	       22:
		 begin
		    reg_address_r <= 8'h9A;
		    reg_data_r    <= 8'h14;
		 end
	       23:
		 begin
		    reg_address_r <= 8'h9C;
		    reg_data_r    <= 8'h3F;
		 end
	       24:
		 begin
		    reg_address_r <= 8'hA5;
		    reg_data_r    <= 8'h19;
		 end
	       25:
		 begin
		    reg_address_r <= 8'hCC;
		    reg_data_r    <= 8'h19;
		 end
	       26:
		 begin
		    reg_address_r <= 8'hCD;
		    reg_data_r    <= 8'h0B;
		 end
	       27:
		 begin
		    reg_address_r <= 8'hCE;
		    reg_data_r    <= 8'h13;
		 end
	       28:
		 begin
		    reg_address_r <= 8'hCF;
		    reg_data_r    <= 8'h64;
		 end
	       29:
		 begin
		    reg_address_r <= 8'hD0;
		    reg_data_r    <= 8'h21;
		 end
	       30:
		 begin
		    reg_address_r <= 8'hEF;
		    reg_data_r    <= 8'h01;
		 end
	       31:
		 begin
		    reg_address_r <= 8'h02;
		    reg_data_r    <= 8'h0F;
		 end
	       32:
		 begin
		    reg_address_r <= 8'h03;
		    reg_data_r    <= 8'h10;
		 end
	       33:
		 begin
		    reg_address_r <= 8'h04;
		    reg_data_r    <= 8'h02;
		 end
	       34:
		 begin
		    reg_address_r <= 8'h25;
		    reg_data_r    <= 8'h01;
		 end
	       35:
		 begin
		    reg_address_r <= 8'h27;
		    reg_data_r    <= 8'h39;
		 end
	       36:
		 begin
		    reg_address_r <= 8'h28;
		    reg_data_r    <= 8'h7F;
		 end
	       37:
		 begin
		    reg_address_r <= 8'h29;
		    reg_data_r    <= 8'h08;
		 end
	       38:
		 begin
		    reg_address_r <= 8'h3E;
		    reg_data_r    <= 8'hFF;
		 end
	       39:
		 begin
		    reg_address_r <= 8'h5E;
		    reg_data_r    <= 8'h3D;
		 end
	       40:
		 begin
		    reg_address_r <= 8'h65;
		    reg_data_r    <= 8'h96;
		 end
	       41:
		 begin
		    reg_address_r <= 8'h67;
		    reg_data_r    <= 8'h97;
		 end
	       42:
		 begin
		    reg_address_r <= 8'h69;
		    reg_data_r    <= 8'hCD;
		 end
	       43:
		 begin
		    reg_address_r <= 8'h6A;
		    reg_data_r    <= 8'h01;
		 end
	       44:
		 begin
		    reg_address_r <= 8'h6D;
		    reg_data_r    <= 8'h2C;
		 end
	       45:
		 begin
		    reg_address_r <= 8'h6E;
		    reg_data_r    <= 8'h01;
		 end
	       46:
		 begin
		    reg_address_r <= 8'h72;
		    reg_data_r    <= 8'h01;
		 end
	       47:
		 begin
		    reg_address_r <= 8'h73;
		    reg_data_r    <= 8'h35;
		 end
	       48:
		 begin
		    reg_address_r <= 8'h77;
		    reg_data_r    <= 8'h01;
		 end
	       49:
		 begin
		    reg_address_r <= 8'hEF;
		    reg_data_r    <= 8'h00;
		 end
	       50:
		 begin
		    reg_address_r <= 8'h41;
		    reg_data_r    <= 8'hFF;
		 end
	       
	       default:
		 begin
		    reg_address_r <= zero_p;
		    reg_data_r    <= zero_p;
		 end
	     endcase
	  end
     end
  
   always @ (posedge Clk_i or negedge Reset_i)  // I2C clock time period counter
     begin
	if(Reset_i == low_p)
	  begin
	     i2c_duty_cycle_counter_r <= zero_p;
	  end
	else
	  begin
	     if(scl_start_r == high_p && i2c_duty_cycle_counter_r < i2c_time_period)
	       begin
		  i2c_duty_cycle_counter_r <= i2c_duty_cycle_counter_r + high_p;
	       end
	     else
	       begin
		  i2c_duty_cycle_counter_r <= zero_p;
	       end
	  end
     end 

   always @ (posedge Clk_i or negedge Reset_i)  // I2C clock
     begin
	if(Reset_i == low_p)
	  begin
	     scl_r <= high_p;
	  end
	else
	  begin
	     if(i2c_duty_cycle_counter_r < positive_edge_p)
	       begin
		  scl_r <= high_p;
	       end
	     else
	       begin
		  scl_r <= low_p;
	       end
	  end
     end

    always @ (posedge Clk_i or negedge Reset_i) // Delay SCL signal
     begin
	if(Reset_i == low_p)
	  begin
	     scl_delay_r <= low_p;
	  end
	else
	  begin
	     scl_delay_r <= scl_r;
	  end
     end

   always @ (posedge Clk_i or negedge Reset_i) // To detect rise, fall and active region of SCL signal
     begin
	if(Reset_i == low_p)
	  begin
	     scl_active_region <= low_p;
	     scl_fall_edge_r   <= low_p;
	  end
	else
	  begin
	     if(scl_r == high_p && scl_delay_r == low_p)
	       begin
		  scl_active_region <= high_p;
		  scl_fall_edge_r   <= low_p;
	       end
	     else if (scl_r == low_p && scl_delay_r == high_p)
	       begin	  
		  scl_active_region <= low_p;
		  scl_fall_edge_r   <= high_p;
	       end
	     else
	       begin
		  scl_active_region <= scl_active_region;
		  scl_fall_edge_r   <= low_p;
	       end
	  end
     end

   always @ (posedge Clk_i or negedge Reset_i)  // I2C clock cycles counter for 8 bit data 
     begin
	if(Reset_i == low_p)
	  begin
	     i2c_clock_counter_r <= zero_p;
	  end
	else
	  begin
	     if((next_state_r == i2c_fsm_slave_address_p || next_state_r ==  i2c_fsm_reg_address_p || next_state_r == i2c_fsm_data_to_write_p) && scl_fall_edge_r == high_p &&  i2c_clock_counter_r < eight_clock_cycles_p - high_p)
	       begin
		  i2c_clock_counter_r <= i2c_clock_counter_r + high_p;
	       end
	     else if ((next_state_r == i2c_fsm_slave_address_p || next_state_r == i2c_fsm_reg_address_p || next_state_r == i2c_fsm_data_to_write_p) && scl_fall_edge_r == high_p &&  i2c_clock_counter_r == eight_clock_cycles_p - high_p)
	       begin
		  i2c_clock_counter_r <= zero_p;
	       end
	     else
	       begin
		  i2c_clock_counter_r <= i2c_clock_counter_r;
	       end
	  end
     end

   always @ (posedge Clk_i or negedge Reset_i)  // For debugging purposes (to see the response of slave device)
     begin
	if(Reset_i == low_p)
	  begin
	     sda_read_r <= high_p;
	  end
	else
	  begin
	     if((next_state_r == i2c_fsm_slave_ack_p || next_state_r ==  i2c_fsm_data_to_write_p))
	       begin
		  sda_read_r <= SDA_io;
	       end
	     else
	       begin
		  sda_read_r <= high_p;
	       end
	  end
     end
   
   always @ (posedge Clk_i or negedge Reset_i)  // FSM for I2C
     begin
	if(Reset_i == low_p)
	  begin
	     next_state_r        		 <= i2c_fsm_idle_p;
	     previous_state_r    		 <= i2c_fsm_idle_p;
	     scl_start_r         		 <= low_p;
	     read_write_r        		 <= low_p;
	     sda_r               		 <= high_p;
	     wait_counter_r      		 <= all_ones_p;
	     single_read_frame_count_r           <= zero_p;
	     data_available_r                    <= low_p;
	  end
	else
	  begin
	     case(next_state_r)
	       i2c_fsm_idle_p:
		 begin
		    if(Switch_i == high_p || single_read_frame_count_r != zero_p)
		      begin
			 next_state_r     <= i2c_fsm_start_p;
			 previous_state_r <= i2c_fsm_idle_p;
			 scl_start_r      <= high_p;
			 sda_r            <= low_p;
		      end
		    else
		      begin
			 next_state_r     <= i2c_fsm_idle_p;
			 previous_state_r <= previous_state_r;
			 scl_start_r      <= low_p;
			 sda_r            <= high_p;
		      end
		    read_write_r   	      <= low_p;
		    wait_counter_r 	      <= zero_p;
		    single_read_frame_count_r <= single_read_frame_count_r;
		    data_available_r          <= low_p;
		 end
	       i2c_fsm_start_p:
		 begin
		    if(scl_fall_edge_r == high_p)
		      begin
			 next_state_r     <= i2c_fsm_slave_address_p;
			 previous_state_r <= i2c_fsm_start_p;
			 sda_r            <= slave_address_r[eight_clock_cycles_p - high_p - i2c_clock_counter_r];
		      end
		    else
		      begin
			 next_state_r     <= next_state_r;
			 previous_state_r <= previous_state_r;
			 sda_r            <= sda_r;
		      end
		    scl_start_r   				<= scl_start_r;
		    read_write_r  				<= read_write_r;
		    wait_counter_r 				<= wait_counter_r;
		    single_read_frame_count_r <= single_read_frame_count_r;
		    data_available_r <= data_available_r;
		 end
	       i2c_fsm_slave_address_p:
		 begin
		    if(scl_fall_edge_r == high_p && i2c_clock_counter_r == eight_clock_cycles_p - high_p)
		      begin
			 next_state_r     <= i2c_fsm_slave_ack_p;
			 previous_state_r <= i2c_fsm_slave_address_p;
			 sda_r            <= high_p;
		      end
		    else
		      begin
			 next_state_r     <= next_state_r;
			 previous_state_r <= previous_state_r;
			 sda_r            <= slave_address_r[eight_clock_cycles_p - high_p - i2c_clock_counter_r];
		      end
		    scl_start_r    				<= scl_start_r;
		    read_write_r   				<= read_write_r;
		    wait_counter_r 				<= wait_counter_r;
		    single_read_frame_count_r <= single_read_frame_count_r;
		    data_available_r <= data_available_r;
		 end
	       i2c_fsm_slave_ack_p:
		 begin
		    if(scl_fall_edge_r == high_p && previous_state_r == i2c_fsm_slave_address_p)       //Write
		      begin
			 next_state_r     			<= i2c_fsm_reg_address_p;
			 previous_state_r 			<= i2c_fsm_slave_ack_p;
			 sda_r            			<= reg_address_r[eight_clock_cycles_p - high_p - i2c_clock_counter_r];
			 single_read_frame_count_r <= single_read_frame_count_r;
		      end
		    else if (scl_fall_edge_r == high_p && previous_state_r == i2c_fsm_reg_address_p) // Next repeated start 
		      begin
			 next_state_r                           <= i2c_fsm_data_to_write_p;
			 previous_state_r 			<= i2c_fsm_slave_ack_p;
			 sda_r                                  <= reg_data_r[eight_clock_cycles_p - high_p - i2c_clock_counter_r];
			 single_read_frame_count_r <= single_read_frame_count_r;
		      end
		    else if (scl_fall_edge_r == high_p && previous_state_r ==  i2c_fsm_data_to_write_p)
		      begin
			 next_state_r     			<= i2c_fsm_stop_p;
			 previous_state_r 			<= i2c_fsm_slave_ack_p;
			 sda_r            			<= low_p;
			 single_read_frame_count_r <= single_read_frame_count_r + high_p;
		      end
		    else
		      begin
			 next_state_r     			<= next_state_r;
			 previous_state_r 			<= previous_state_r;
			 sda_r            			<= sda_r;
			 single_read_frame_count_r <= single_read_frame_count_r;
		      end
		    scl_start_r    <= scl_start_r;
		    read_write_r   <= read_write_r;
		    wait_counter_r <= wait_counter_r;
		    data_available_r <= data_available_r;
		 end
	       i2c_fsm_reg_address_p:
		 begin
		    if(scl_fall_edge_r == high_p && i2c_clock_counter_r == eight_clock_cycles_p - high_p)
		      begin
			 next_state_r     <= i2c_fsm_slave_ack_p;
			 previous_state_r <= i2c_fsm_reg_address_p;
			 sda_r            <= high_p;
		      end
		    else
		      begin
			 next_state_r     <= next_state_r;
			 previous_state_r <= previous_state_r;
			 sda_r            <= reg_address_r[eight_clock_cycles_p - high_p - i2c_clock_counter_r];
		      end
		    scl_start_r               <= scl_start_r;
		    read_write_r              <= high_p;
		    wait_counter_r            <= wait_counter_r;
		    single_read_frame_count_r <= single_read_frame_count_r;
		    data_available_r <= data_available_r;
		 end
	       i2c_fsm_data_to_write_p:
		 begin
		    if(scl_fall_edge_r == high_p && i2c_clock_counter_r == eight_clock_cycles_p - high_p)
		      begin
			 next_state_r     <= i2c_fsm_slave_ack_p;
			 previous_state_r <= i2c_fsm_data_to_write_p;
			 sda_r            <= high_p;
		      end
		    else
		      begin
			 next_state_r     <= next_state_r;
			 previous_state_r <= previous_state_r;
			 sda_r            <= reg_data_r[eight_clock_cycles_p - high_p - i2c_clock_counter_r];
		      end
		    scl_start_r               <= scl_start_r;
		    read_write_r              <= read_write_r;
		    wait_counter_r            <= wait_counter_r;
		    single_read_frame_count_r <= single_read_frame_count_r;
		    data_available_r <= data_available_r;
		 end
	       i2c_fsm_stop_p:
		 begin
		    if(scl_active_region == high_p && wait_counter_r == wait_time_p && single_read_frame_count_r < registers_to_write_p)
		      begin
			 next_state_r     <= i2c_fsm_idle_p;
			 previous_state_r <= i2c_fsm_stop_p;
			 scl_start_r      <= scl_start_r;
			 read_write_r     <= read_write_r;
			 sda_r            <= sda_r;
			 wait_counter_r   <= zero_p;
			 data_available_r <= low_p;
		      end
		    else if (scl_active_region == high_p && wait_counter_r < wait_time_p && wait_counter_r > positive_edge_p)
		      begin
			 next_state_r      <= next_state_r;
			 previous_state_r  <= previous_state_r;
			 scl_start_r       <= scl_start_r;
			 read_write_r      <= read_write_r;
			 sda_r             <= sda_r;
			 wait_counter_r    <= wait_counter_r + high_p;
			 data_available_r  <= low_p;
		      end
		    else if (scl_active_region == high_p && wait_counter_r < positive_edge_p) // For SDA to be asserted
		      begin
			 next_state_r      <= next_state_r;
			 previous_state_r  <= previous_state_r;
			 scl_start_r       <= low_p;
			 read_write_r      <= low_p;
			 sda_r             <= low_p;
			 wait_counter_r    <= wait_counter_r + high_p;
			 data_available_r  <= low_p;
		      end
		    else if (scl_active_region == high_p && wait_counter_r == positive_edge_p)
		      begin
			 next_state_r      <= next_state_r;
			 previous_state_r  <= previous_state_r;
			 scl_start_r       <= scl_start_r;
			 read_write_r      <= low_p;
			 sda_r             <= high_p;
			 wait_counter_r    <= wait_counter_r + high_p;
			 data_available_r  <= high_p;
		      end
		    else
		      begin
			 next_state_r     <= next_state_r;
			 previous_state_r <= previous_state_r;
			 scl_start_r      <= scl_start_r;
			 read_write_r     <= read_write_r;
			 sda_r            <= sda_r;
			 wait_counter_r   <= wait_counter_r;
			 data_available_r <= low_p;
		      end
		    single_read_frame_count_r <= single_read_frame_count_r;
		 end
	       default:
		 begin
		    next_state_r     			<= i2c_fsm_idle_p;
		    previous_state_r 			<= i2c_fsm_idle_p;
		    scl_start_r      			<= low_p;
		    read_write_r     			<= low_p;
		    sda_r            			<= high_p;
		    wait_counter_r   			<= zero_p;
		    single_read_frame_count_r           <= low_p;
		    data_available_r                    <= low_p;
		 end
	     endcase
	  end
     end
			
   always @ (posedge Clk_i or negedge Reset_i)  // Indicates configuration is done 
     begin
	if(Reset_i == low_p)
	  begin
	     write_config_done_r <= low_p;
	  end
	else
	  begin
	     if(scl_active_region == high_p && wait_counter_r == wait_time_p && single_read_frame_count_r == registers_to_write_p)
	       begin
		  write_config_done_r <= high_p;
	       end
	     else
	       begin
		  write_config_done_r <= write_config_done_r;
	       end
	  end
     end

   assign SCL_o            = scl_r;
   assign SDA_io           = sda_r ? 1'bZ : low_p;
   assign Debug_o          = sda_read_r;
   assign Data_Available_o = write_config_done_r;

endmodule
