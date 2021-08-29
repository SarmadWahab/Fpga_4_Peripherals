`timescale 1ns / 1ps
`include "give_your_local_location\adxl345_parameters.v"
//////////////////////////////////////////////////////////////////////////////////
// Company:        DIY Projects 
// Engineer:       Sarmad Wahab 
// Create Date:    20:24:44 08/26/2021   
// Design Name:    Adxl345 Sensor   
// Module Name:    i2c_controller   
// Target Devices: Xilin Spartan 6     
// Tool versions:  Design ISE 14.7  
////////////////////////////////////////////////////////////////////////////////////

module i2c_controller(
	Clk_i,
	Reset_i,
        Switch_i,
        SDA_io,
        SCL_o,
        CS_o,
	X_o,
	Y_o,
	Z_o,
	Data_Available_o,
	Debug_o
    );
     
	parameter fsm_idle_p                              = 2'b00;

	input                                               Clk_i,Reset_i,Switch_i;
        inout                                               SDA_io;
        output                                              SCL_o,CS_o,Data_Available_o,Debug_o;
	output signed [offset_p                        : 0] X_o;
	output signed [offset_p                        : 0] Y_o;
	output signed [offset_p                        : 0] Z_o;
   
	reg                                                 i2c_single_read_done_r;
        reg                                                 i2c_single_write_activated_r;
        reg                                                 i2c_burst_read_activated_r;
        reg                                                 i2c_write_config_done_r;
        wire                                                single_read_data_available_w;
        wire                                                single_write_data_available_w;
	wire                                                burst_read_data_available_w;	
	wire                                                cs_0_w,cs_1_w,cs_2_w;
	wire                                                scl_0_w,scl_1_w,scl_2_w;
	wire                                                sda_0_w,sda_1_w,sda_2_w;
	wire                                                dbg_0_w,dbg_1_w,dbg_2_w;
        wire 						    d_a;

        reg         [high_p                            : 0] next_state_r;
        reg         [i2c_duty_cycle_counter_length_p   : 0] wait_counter_r;
        wire        [characteristics_mantissa_length_p : 0] data_w;
        wire signed [offset_p                          : 0] x_w;
	wire signed [offset_p                          : 0] y_w;
	wire signed [offset_p                          : 0] z_w;
	
   
   always @ (posedge Clk_i or negedge Reset_i)        // This FSM is responsible to synchronize the between single read , single write & burst read. Single read and single write are executed once whereas burst read is executed continiously  
     begin
	if(Reset_i == low_p)
	  begin
	     next_state_r                 <= fsm_idle_p;
	     wait_counter_r               <= zero_p;
	     i2c_single_write_activated_r <= low_p;
	     i2c_write_config_done_r      <= low_p;
	     i2c_burst_read_activated_r   <= low_p;
	     i2c_single_read_done_r       <= low_p;
	  end
	else
	  begin
	     case(next_state_r)
	       fsm_idle_p:
		 begin
		    if(single_read_data_available_w == high_p)
		      begin
			 next_state_r           <= fsm_wait_p;
			 i2c_single_read_done_r <= high_p;
		      end
		    else
		      begin
			 next_state_r            <= fsm_idle_p;
			 i2c_single_read_done_r  <= low_p;
		      end
		    wait_counter_r               <= zero_p;
		    i2c_single_write_activated_r <= low_p;
		    i2c_write_config_done_r      <= low_p;
		    i2c_burst_read_activated_r   <= low_p;
		 end
	       fsm_wait_p:
		 begin
		    if(wait_counter_r == stop_time_p && i2c_write_config_done_r == low_p)
		      begin
			 next_state_r                 <= fsm_activate_p;
			 wait_counter_r               <= zero_p;
			 i2c_single_write_activated_r <= high_p;
			 i2c_burst_read_activated_r   <= low_p;
		      end
		    else if (wait_counter_r == stop_time_p && i2c_write_config_done_r == high_p)
		      begin
			 next_state_r                 <= fsm_activate_p;
			 wait_counter_r               <= zero_p;
			 i2c_single_write_activated_r <= low_p;
			 i2c_burst_read_activated_r   <= high_p;
		      end
		    else
		      begin
			 next_state_r                 <= next_state_r;
			 wait_counter_r               <= wait_counter_r + high_p;
			 i2c_single_write_activated_r <= low_p;
			 i2c_burst_read_activated_r   <= low_p;
		      end
		    i2c_write_config_done_r <= i2c_write_config_done_r;
		    i2c_single_read_done_r  <= i2c_single_read_done_r;
		 end
	       fsm_activate_p:
		 begin
		    if(single_write_data_available_w == high_p)
		      begin
			 next_state_r                 <= fsm_wait_p;
			 i2c_write_config_done_r      <= high_p;
		      end
		    else
		      begin
			 next_state_r                 <= next_state_r;
			 i2c_write_config_done_r      <= i2c_write_config_done_r;
		      end
		    wait_counter_r               <= wait_counter_r;
		    i2c_single_write_activated_r <= low_p;
		    i2c_burst_read_activated_r   <= i2c_burst_read_activated_r;
		    i2c_single_read_done_r       <= i2c_single_read_done_r;
		 end
	       default:
		 begin
		    next_state_r                 <= fsm_idle_p;
		    wait_counter_r               <= zero_p;
		    i2c_single_write_activated_r <= low_p;
		    i2c_write_config_done_r      <= low_p;
		    i2c_burst_read_activated_r   <= low_p;
		    i2c_single_read_done_r       <= low_p;
		 end
	     endcase
	  end
     end
   
    i2c_single_read i2c_single_read (                 // This IP is responsible to generate single read frame for I2C (It can be executed once or continious)
    .Clk_i(Clk_i), 
    .Reset_i(Reset_i), 
    .Switch_i(Switch_i), 
    .SDA_io(SDA_io), 
    .SCL_o(scl_0_w), 
    .Debug_o(dbg_0_w), 
    .CS_o(cs_0_w), 
    .Data_Available_o(single_read_data_available_w)
    );
	
    i2c_single_write i2c_single_write (               // This IP is responsible to generate single write frame for I2C (It can be executed once or continious)
    .Clk_i(Clk_i), 
    .Reset_i(Reset_i), 
    .Switch_i(i2c_single_write_activated_r), 
    .SDA_io(SDA_io), 
    .SCL_o(scl_1_w), 
    .Debug_o(dbg_1_w), 
    .CS_o(cs_1_w), 
    .Data_Available_o(single_write_data_available_w)
    );
	
    i2c_burst_read i2c_burst_read (                   // This IP is responsible to generate burst read frame for I2C (It can be executed once or continious)
    .Clk_i(Clk_i), 
    .Reset_i(Reset_i), 
    .Switch_i(i2c_burst_read_activated_r), 
    .SDA_io(SDA_io), 
    .SCL_o(scl_2_w), 
    .Debug_o(dbg_2_w), 
    .CS_o(cs_2_w), 
    .Data_Available_o(burst_read_data_available_w),
    .X_o(x_w),
    .Y_o(y_w),
    .Z_o(z_w)
    );

    assign SCL_o            = (!i2c_single_read_done_r) ? scl_0_w : (!i2c_write_config_done_r ? scl_1_w : scl_2_w);
    assign Debug_o          = (!i2c_single_read_done_r) ? dbg_0_w : (!i2c_write_config_done_r ? dbg_1_w : dbg_2_w);
    assign CS_o             = (!i2c_single_read_done_r) ? cs_0_w  : (!i2c_write_config_done_r ? cs_1_w  : cs_2_w);
    assign X_o              = x_w;
    assign Y_o              = y_w;
    assign Z_o              = z_w;
    assign Data_Available_o = burst_read_data_available_w;
   
endmodule
