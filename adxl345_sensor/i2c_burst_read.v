`timescale 1ns / 1ps
`include "give_your_local_location\adxl345_parameters.v"
//////////////////////////////////////////////////////////////////////////////////
// Company:        DIY Projects 
// Engineer:       Sarmad Wahab 
// Create Date:    21:35:22 08/26/2021
// Design Name:    Adxl345 Sensor
// Module Name:    i2c_burst_read
// Target Devices: Xilinx Spartan 6 
// Tool versions:  Design ISE 14.7 
//////////////////////////////////////////////////////////////////////////////////
module i2c_burst_read(
   Clk_i,
   Reset_i,
   Switch_i,
   SDA_io,
   SCL_o,
   Debug_o,
   CS_o,
   Data_Available_o,
   X_o,
   Y_o,
   Z_o
    );
  
   parameter i2c_fsm_stop_p                = 3'd7;
   parameter slave_address_p               = 8'h53;
   parameter wait_time_p                   = 21'd1400000;

   input                                     Clk_i,Reset_i,Switch_i;
   inout                                     SDA_io;
   output                                    SCL_o,Debug_o,CS_o,Data_Available_o;
   output signed [offset_p              : 0] X_o;
   output signed [offset_p              : 0] Y_o;
   output signed [offset_p              : 0] Z_o;

   reg                                       sda_r;
   reg                                       scl_r;
   reg                                       scl_delay_r;
   reg                                       scl_fall_edge_r;
   reg                                       scl_active_region;
   reg                                       scl_start_r;
   reg                                       read_write_r;
   reg                                       sda_read_r;
   reg                                       data_available_r;
 
   reg [i2c_fsm_state_length_p          : 0] next_state_r;
   reg [i2c_fsm_state_length_p          : 0] previous_state_r;
   reg [i2c_fsm_state_length_p          : 0] i2c_clock_counter_r;
   reg [i2c_duty_cycle_counter_length_p : 0] i2c_duty_cycle_counter_r;
   reg [eight_clock_cycles_p-high_p     : 0] slave_address_r;
   reg [eight_clock_cycles_p-high_p     : 0] reg_address_r;
   reg [delay_p                         : 0] wait_counter_r;
   reg [i2c_fsm_state_length_p          : 0] axes_counter_r;
   reg [high_p                          : 0] single_read_frame_count_r;
   reg signed [offset_p                 : 0] x_axes_r;
   reg signed [offset_p                 : 0] y_axes_r;
   reg signed [offset_p                 : 0] z_axes_r;

	

	
   always @ (posedge Clk_i or negedge Reset_i)  // This block is responsible to store X Y & Z axes data in signed form 
     begin
	if(Reset_i == low_p)
	  begin
	     x_axes_r <= zero_p;
	     y_axes_r <= zero_p;
	     z_axes_r <= zero_p;
	  end
	else
	  begin
	     case(axes_counter_r)
	       0:
		 begin
		    if(next_state_r == i2c_fsm_data_to_read_p)
		      begin
			 x_axes_r[i2c_clock_counter_r] <= SDA_io;
		      end
		    else
		      begin
			 x_axes_r <= x_axes_r;
		      end
		 end
	       1:
		 begin
		    if(next_state_r == i2c_fsm_data_to_read_p)
		      begin
			 x_axes_r[i2c_clock_counter_r+eight_clock_cycles_p] <= SDA_io; 
		      end
		    else
		      begin
			 x_axes_r <= x_axes_r;
		      end
		 end
	       2:
		 begin
		    if(next_state_r == i2c_fsm_data_to_read_p)
		      begin
			 y_axes_r[i2c_clock_counter_r] <= SDA_io;
			 
		      end
		    else
		      begin
			 y_axes_r <= y_axes_r;
		      end
		 end
	       3:
		 begin
		    if(next_state_r == i2c_fsm_data_to_read_p)
		      begin
			 y_axes_r[i2c_clock_counter_r+eight_clock_cycles_p] <= SDA_io;
		      end
		    else
		      begin
			 y_axes_r <= y_axes_r;
		      end
		 end
	       4:
		 begin
		    if(next_state_r == i2c_fsm_data_to_read_p)
		      begin
			 z_axes_r[i2c_clock_counter_r] <= SDA_io;
		      end
		    else
		      begin
			 z_axes_r <= z_axes_r;
		      end
		 end
	       5:
		 begin
		    if(next_state_r == i2c_fsm_data_to_read_p)
		      begin
			 z_axes_r[i2c_clock_counter_r+eight_clock_cycles_p] <= SDA_io;
		      end
		    else
		      begin
			 z_axes_r <= z_axes_r;
		      end
		 end
	       default:
		 begin
		    x_axes_r <= x_axes_r;
		    y_axes_r <= y_axes_r;
		    z_axes_r <= z_axes_r;
		 end
	     endcase
	  end
     end

   always @ (posedge Clk_i or negedge Reset_i)  // This block is responsible to update slave address
     begin
	if(Reset_i == low_p)
	  begin
	     slave_address_r <= zero_p;
	  end
	else
	  begin
	     slave_address_r <= {slave_address_p,read_write_r};
	  end
     end

   always @ (posedge Clk_i or negedge Reset_i)  // This block is responsible to update the register values for read operation 
     begin
	if(Reset_i == low_p)
	  begin
	     reg_address_r <= zero_p;
	  end
	else
	  begin
	     reg_address_r <= 8'h32;
	  end
     end

   always @ (posedge Clk_i or negedge Reset_i) // This block is represent timer period for I2C clock   
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

   always @ (posedge Clk_i or negedge Reset_i)  // This block is responsible for generation of I2C clock 
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

   always @ (posedge Clk_i or negedge Reset_i) // This block is responsible to delay I2C clock one cycle 
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


   always @ (posedge Clk_i or negedge Reset_i)  // This block is responsible to fall and active region of SCL signal
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

   always @ (posedge Clk_i or negedge Reset_i)  // This block is responsible to perform eight cycle counting for reading data 
     begin
	if(Reset_i == low_p)
	  begin
	     i2c_clock_counter_r <= zero_p;
	  end
	else
	  begin
	     if((next_state_r == i2c_fsm_slave_address_p || next_state_r ==  i2c_fsm_reg_address_p || next_state_r == i2c_fsm_data_to_read_p) && scl_fall_edge_r == high_p &&  i2c_clock_counter_r < eight_clock_cycles_p - high_p)
	       begin
		  i2c_clock_counter_r <= i2c_clock_counter_r + high_p;
	       end
	     else if ((next_state_r == i2c_fsm_slave_address_p || next_state_r == i2c_fsm_reg_address_p || next_state_r == i2c_fsm_data_to_read_p) && scl_fall_edge_r == high_p &&  i2c_clock_counter_r == eight_clock_cycles_p - high_p)
	       begin
		  i2c_clock_counter_r <= zero_p;
	       end
	     else
	       begin
		  i2c_clock_counter_r <= i2c_clock_counter_r;
	       end
	  end
     end

   always @ (posedge Clk_i or negedge Reset_i)  // This block is responsible to capture the response of Slave Device 
     begin
	if(Reset_i == low_p)
	  begin
	     sda_read_r <= high_p;
	  end
	else
	  begin
	     if((next_state_r == i2c_fsm_slave_ack_p || next_state_r ==  i2c_fsm_data_to_read_p))
	       begin
		  sda_read_r <= SDA_io;
	       end
	     else
	       begin
		  sda_read_r <= high_p;
	       end
	  end
     end

   always @ (posedge Clk_i or negedge Reset_i)  // This is FSM for I2C covering the logics for single burst read operation 
     begin
	if(Reset_i == low_p)
	  begin
	     next_state_r        		 <= i2c_fsm_idle_p;
	     previous_state_r    		 <= i2c_fsm_idle_p;
	     scl_start_r         		 <= low_p;
	     read_write_r        		 <= low_p;
	     sda_r               		 <= high_p;
	     wait_counter_r      		 <= zero_p;
	     single_read_frame_count_r           <= low_p;
	     axes_counter_r                      <= low_p;
	     data_available_r                    <= low_p;
	  end
	else
	  begin
	     case(next_state_r)
	       i2c_fsm_idle_p:
		 begin
		    if(Switch_i == high_p)
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
		    read_write_r   				<= low_p;
		    wait_counter_r 				<= zero_p;
		    single_read_frame_count_r                   <= single_read_frame_count_r;
		    axes_counter_r                              <= low_p;
		    data_available_r                            <= low_p;
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
		    single_read_frame_count_r                   <= single_read_frame_count_r;
		    axes_counter_r                              <= axes_counter_r;
		    data_available_r                            <= data_available_r;
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
		    single_read_frame_count_r                   <= single_read_frame_count_r;
		    axes_counter_r                              <= axes_counter_r;
		    data_available_r                            <= data_available_r;
		 end
	       i2c_fsm_slave_ack_p:
		 begin
		    if(scl_fall_edge_r == high_p && previous_state_r == i2c_fsm_slave_address_p && read_write_r == low_p)
		      begin
			 next_state_r     			<= i2c_fsm_reg_address_p;
			 previous_state_r 			<= i2c_fsm_slave_ack_p;
			 sda_r            			<= reg_address_r[eight_clock_cycles_p - high_p - i2c_clock_counter_r];
			 single_read_frame_count_r              <= single_read_frame_count_r;
			 axes_counter_r                         <= axes_counter_r;
		      end
		    else if (scl_fall_edge_r == high_p && previous_state_r == i2c_fsm_reg_address_p && read_write_r == high_p) 
		      begin
			 next_state_r     			<= i2c_fsm_repeated_start_p;
			 previous_state_r 			<= i2c_fsm_slave_ack_p;
			 sda_r            			<= high_p;
			 single_read_frame_count_r              <= single_read_frame_count_r;
			 axes_counter_r                         <= axes_counter_r;
		      end
		    else if (scl_fall_edge_r == high_p && previous_state_r == i2c_fsm_slave_address_p && read_write_r == high_p)
		      begin
			 next_state_r     			<= i2c_fsm_data_to_read_p;
			 previous_state_r 			<= i2c_fsm_slave_ack_p;
			 sda_r            			<= high_p;
			 single_read_frame_count_r              <= single_read_frame_count_r;
			 axes_counter_r                         <= axes_counter_r;
		      end
		    else if (scl_fall_edge_r == high_p && previous_state_r ==  i2c_fsm_data_to_read_p && read_write_r == high_p)
		      begin
			 if(axes_counter_r == number_of_axes_p)
			   begin
			      next_state_r     			<= i2c_fsm_stop_p;
			      previous_state_r 			<= i2c_fsm_slave_ack_p;
			      sda_r            			<= low_p;
			      single_read_frame_count_r         <= single_read_frame_count_r;
			      axes_counter_r                    <= low_p;
			   end
			 else
			   begin
			      next_state_r     			<= i2c_fsm_data_to_read_p;
			      previous_state_r 			<= i2c_fsm_slave_ack_p;
			      sda_r            			<= high_p;
			      single_read_frame_count_r          <= single_read_frame_count_r;
			      axes_counter_r                     <= axes_counter_r; 
			   end
		      end
		    else
		      begin
			 next_state_r     			<= next_state_r;
			 previous_state_r 			<= previous_state_r;
			 sda_r            			<= sda_r;
			 single_read_frame_count_r              <= single_read_frame_count_r;
			 axes_counter_r                         <= axes_counter_r;
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
		    axes_counter_r            <= axes_counter_r;
		    data_available_r          <= data_available_r;
		 end
	       i2c_fsm_repeated_start_p:
		 begin
		    if(scl_active_region == high_p && wait_counter_r == positive_edge_p)
		      begin
			 next_state_r     <= i2c_fsm_start_p;
			 previous_state_r <= i2c_fsm_repeated_start_p;
			 scl_start_r      <= high_p;
			 sda_r            <= low_p;
			 wait_counter_r   <= zero_p;
		      end
		    else if (scl_active_region == high_p && wait_counter_r < positive_edge_p)
		      begin
			 next_state_r     <= next_state_r;
			 previous_state_r <= previous_state_r;
			 scl_start_r      <= low_p;
			 sda_r            <= sda_r;
			 wait_counter_r   <= wait_counter_r + high_p;
		      end
		    else
		      begin
			 next_state_r     <= next_state_r;
			 previous_state_r <= previous_state_r;
			 scl_start_r      <= scl_start_r;
			 sda_r            <= sda_r;
			 wait_counter_r   <= wait_counter_r;
		      end
		    read_write_r              <= read_write_r;
		    single_read_frame_count_r <= single_read_frame_count_r;
		    axes_counter_r            <= axes_counter_r;
		    data_available_r          <= data_available_r;
		 end
	       i2c_fsm_data_to_read_p:
		 begin
		    if(scl_fall_edge_r == high_p && i2c_clock_counter_r == eight_clock_cycles_p - high_p && axes_counter_r < number_of_axes_p - high_p)
		      begin
			 next_state_r     <= i2c_fsm_slave_ack_p;
			 previous_state_r <= i2c_fsm_data_to_read_p;
			 sda_r            <= low_p;
			 axes_counter_r   <= axes_counter_r + high_p;
		      end
		    else if (scl_fall_edge_r == high_p && i2c_clock_counter_r == eight_clock_cycles_p - high_p && axes_counter_r == number_of_axes_p - high_p)
		      begin
			 next_state_r     <= i2c_fsm_slave_ack_p;
			 previous_state_r <= i2c_fsm_data_to_read_p;
			 sda_r            <= high_p;
			 axes_counter_r   <= axes_counter_r + high_p;
		      end
		    else
		      begin
			 next_state_r     <= next_state_r;
			 previous_state_r <= previous_state_r;
			 sda_r            <= sda_r;
			 axes_counter_r   <= axes_counter_r;
		      end
		    scl_start_r               <= scl_start_r;
		    read_write_r              <= read_write_r;
		    wait_counter_r            <= wait_counter_r;
		    single_read_frame_count_r <= single_read_frame_count_r;
		    data_available_r          <= data_available_r;
		 end
	       i2c_fsm_stop_p:
		 begin
		    if(scl_active_region == high_p && wait_counter_r == wait_time_p && single_read_frame_count_r < registers_to_read_p)
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
		    else if (scl_active_region == high_p && wait_counter_r < positive_edge_p)
		      begin
			 next_state_r      <= next_state_r;
			 previous_state_r  <= previous_state_r;
			 scl_start_r       <= low_p;
			 read_write_r      <= low_p;
			 sda_r             <= low_p;
			 wait_counter_r    <= wait_counter_r + high_p;
			 data_available_r <= low_p;
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
		    axes_counter_r            <= axes_counter_r;
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
		    axes_counter_r                      <= low_p;
		    data_available_r                    <= low_p;
		 end
	     endcase
	  end
     end

   assign SCL_o            = scl_r;
   assign SDA_io           = sda_r ? 1'bZ : low_p;
   assign Debug_o          = sda_read_r;
   assign CS_o             = high_p;
   assign Data_Available_o = data_available_r;
   assign X_o              = x_axes_r;
   assign Y_o              = y_axes_r;
   assign Z_o              = z_axes_r;

endmodule
