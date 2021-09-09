`timescale 1ns / 1ps
`include "give_your_local_location\paj7620_parameters.v"
//////////////////////////////////////////////////////////////////////////////////
// Company:        DIY Projects
// Engineer:       Sarmad Wahab 
// Create Date:    21:35:22 08/26/2021 
// Design Name:    Paj7620 
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
   Data_Available_o,
   Gesture_o,
   Int_i
    );

  
    parameter i2c_fsm_stop_p           = 3'd7;
    parameter slave_address_p          = 8'h73;
    parameter wait_time_p              = 21'd1400000;
    parameter registers_to_read_p      = 1;
   

    input  Clk_i,Reset_i,Switch_i,Int_i;
    inout  SDA_io;
    output SCL_o,Debug_o,Data_Available_o;
    output [eight_clock_cycles_p-high_p : 0] Gesture_o;

   reg       sda_r;
   reg       scl_r;
   reg       scl_delay_r;
   reg       scl_fall_edge_r;
   reg       scl_active_region;
   reg       scl_start_r;
   reg       read_write_r;
   reg       sda_read_r;
   reg       data_available_r;
   reg       power_is_stable_r;
 
   
   reg [i2c_fsm_state_length_p          : 0] next_state_r;
   reg [i2c_fsm_state_length_p          : 0] previous_state_r;
   reg [i2c_fsm_state_length_p          : 0] i2c_clock_counter_r;
   reg [i2c_duty_cycle_counter_length_p : 0] i2c_duty_cycle_counter_r;
   reg [eight_clock_cycles_p-high_p     : 0] slave_address_r;
   reg [eight_clock_cycles_p-high_p     : 0] reg_address_r;
   reg [delay_p                         : 0] wait_counter_r;
   reg [low_p                           : 0] axes_counter_r;
   reg [offset_p                        : 0] stablization_counter_r;
   reg [high_p                          : 0] single_read_frame_count_r;  // Make it vector for large number of register read
   reg [eight_clock_cycles_p-high_p     : 0] gesture_r;
	

	
   always @  (posedge Clk_i or negedge Reset_i)  // This block is responsbile to store the Gesture value in register
     begin
	if(Reset_i == low_p)
	  begin
	     gesture_r <= zero_p;
	  end
	else
	  begin
	     if(axes_counter_r == zero_p && next_state_r == i2c_fsm_data_to_read_p)
	       begin
		  gesture_r[i2c_clock_counter_r] <= SDA_io;
	       end
	     else
	       begin
		  gesture_r <= gesture_r;
	       end
	  end
     end
	
   always @ (posedge Clk_i or negedge Reset_i)  // This block is responsible for assigning slave address
     begin
	if(Reset_i == low_p)
	  begin
	     slave_address_r <= 8'h19;
	  end
	else
	  begin
	     slave_address_r <= {slave_address_p,read_write_r};
	  end
     end

   
   always @ (posedge Clk_i or negedge Reset_i)  // This block assigned register value for reading
     begin
	if(Reset_i == low_p)
	  begin
	     reg_address_r <= 8'hBC;
	  end
	else
	  begin
	     reg_address_r <= 8'h43;
	  end
     end

   always @ (posedge Clk_i or negedge Reset_i)  // This block is responsibe for counting duty cycle of I2C clock
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

   always @ (posedge Clk_i or negedge Reset_i)  // This block is driving I2C clock 
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

   always @ (posedge Clk_i or negedge Reset_i)  // This block counts clock cycle of I2C clock for register values
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

   always @ (posedge Clk_i or negedge Reset_i)  // This block is used for debugging purposes to check the response from slave
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

   always @ (posedge Clk_i or negedge Reset_i)  // FSM for I2C 
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
		    if(Switch_i == high_p && Int_i == low_p)
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
		    if(scl_fall_edge_r == high_p && previous_state_r == i2c_fsm_slave_address_p && read_write_r == low_p)       //Write
		      begin
			 next_state_r     			<= i2c_fsm_reg_address_p;
			 previous_state_r 			<= i2c_fsm_slave_ack_p;
			 sda_r            			<= reg_address_r[eight_clock_cycles_p - high_p - i2c_clock_counter_r];
			 single_read_frame_count_r              <= single_read_frame_count_r;
			 axes_counter_r                         <= axes_counter_r;
		      end
		    else if (scl_fall_edge_r == high_p && previous_state_r == i2c_fsm_reg_address_p && read_write_r == high_p) // Next repeated start 
		      begin
			 next_state_r     			<= i2c_fsm_repeated_start_p;
			 previous_state_r 			<= i2c_fsm_slave_ack_p;
			 sda_r            			<= high_p;
			 single_read_frame_count_r              <= single_read_frame_count_r;
			 axes_counter_r                         <= axes_counter_r;
		      end
		    else if (scl_fall_edge_r == high_p && previous_state_r == i2c_fsm_slave_address_p && read_write_r == high_p) //Read
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
		    else if (scl_active_region == high_p && wait_counter_r < positive_edge_p) // For SDA to be asserted
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
   assign Data_Available_o = data_available_r;
   assign Gesture_o        = gesture_r;
	
	 



endmodule
