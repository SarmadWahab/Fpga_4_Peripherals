`timescale 1ns / 1ps
`include "give_your_local_location\paj7620_parameters.v"
//////////////////////////////////////////////////////////////////////////////////
// Company:        DIY Projects
// Engineer:       Sarmad Wahab
// 
// Create Date:    20:24:44 08/26/2021 
// Design Name:    Paj7620
// Module Name:    i2c_controller 
// Target Devices: Xilinx Spartan 6 
// Tool versions:  Desing ISE 14.7 
//////////////////////////////////////////////////////////////////////////////////
module i2c_controller(
	Clk_i,
        Reset_i,
        Switch_i,
	Int_i,
        SDA_io,
        SCL_o,
	Gesture_o,
	Data_Available_o,
	Debug_o
    );
	 
   input  Clk_i,Reset_i,Switch_i,Int_i;
   inout  SDA_io;
   output SCL_o,Data_Available_o,Debug_o;
   output [eight_clock_cycles_p-high_p : 0] Gesture_o;

   
   reg i2c_single_read_done_r;
   reg i2c_single_write_activated_r;
   reg i2c_burst_read_activated_r;
   reg i2c_write_config_done_r;

   wire single_read_data_available_w;
   wire single_write_data_available_w;
   wire burst_read_data_available_w;	
   wire scl_0_w,scl_1_w,scl_2_w;
   wire sda_0_w,sda_1_w,sda_2_w;
   wire dbg_0_w,dbg_1_w,dbg_2_w;
   wire d_a;
   

   reg [high_p                             : 0] next_state_r;
   reg [i2c_duty_cycle_counter_length_p    : 0] wait_counter_r;

   wire [eight_clock_cycles_p-high_p       : 0] gesture_w;
   wire [characteristics_mantissa_length_p : 0] data_w;
	
	
	
	
	

   
   always @ (posedge Clk_i or negedge Reset_i)  // FSM for controlling I2C single read/write & burst reads !!!
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
			 next_state_r <= fsm_wait_p;
			 i2c_single_read_done_r <= high_p;
		      end
		    else
		      begin
			 next_state_r <= fsm_idle_p;
			 i2c_single_read_done_r       <= low_p;
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
		    i2c_single_read_done_r  <= i2c_single_read_done_r;
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
 
     i2c_single_read i2c_single_read (                 // This IP perform single I2C read 
    .Clk_i(Clk_i), 
    .Reset_i(Reset_i), 
    .Switch_i(Switch_i),  
    .SDA_io(SDA_io), 
    .SCL_o(scl_0_w), 
    .Debug_o(dbg_0_w),  
    .Data_Available_o(single_read_data_available_w)
    );
	
     i2c_single_write i2c_single_write (               // This IP perform single I2C write
    .Clk_i(Clk_i), 
    .Reset_i(Reset_i), 
    .Switch_i(i2c_single_write_activated_r), 
    .SDA_io(SDA_io), 
    .SCL_o(scl_1_w), 
    .Debug_o(dbg_1_w), 
    .Data_Available_o(single_write_data_available_w)
    );
     i2c_burst_read i2c_burst_read (                  // This IP perform burst read (but here in this project It is performing single read from same address in continious fashion)
    .Clk_i(Clk_i), 
    .Reset_i(Reset_i), 
    .Switch_i(i2c_burst_read_activated_r), 
    .SDA_io(SDA_io), 
    .SCL_o(scl_2_w), 
    .Debug_o(dbg_2_w), 
    .Data_Available_o(burst_read_data_available_w), 
    .Gesture_o(gesture_w),
    .Int_i(Int_i)
    );

    assign SCL_o            = (!i2c_single_read_done_r) ? scl_0_w : (!i2c_write_config_done_r ? scl_1_w : scl_2_w);
    assign Debug_o          = (!i2c_single_read_done_r) ? dbg_0_w : (!i2c_write_config_done_r ? dbg_1_w : dbg_2_w);
    assign Gesture_o        = gesture_w;
    assign Data_Available_o = burst_read_data_available_w;

endmodule
