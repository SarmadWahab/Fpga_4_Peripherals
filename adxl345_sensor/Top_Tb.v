`timescale 1ns / 1ps
`include "C:\Users\Sarmad Wahab\Desktop\adxl345_parameters.v"

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   22:03:05 08/21/2021
// Design Name:   Adxl345_Top
// Module Name:   D:/Spartan_6_Edge_Board/i2c_testing/Top_Tb.v
// Project Name:  i2c_testing
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: Adxl345_Top
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module Top_Tb;
	
	parameter slave_address_p = 8'HE5;
	// Inputs
	reg Clk_i;
	reg Reset_i;
	reg Switch_i;

	// Outputs
	wire SCL;
	wire Tx_o;

	// Bidirs
	reg SDA_io;
	
	reg [2:0] data_counter_r;
	
	reg signed [15:0] x_axes_r;
	reg signed [15:0] y_axes_r;
	reg signed [15:0] z_axes_r;
	

	// Instantiate the Unit Under Test (UUT)
	Adx345_Top instance_name (
    .Clk_i(Clk_i), 
    .Reset_i(Reset_i), 
    .Switch_i(Switch_i), 
    .SDA_io(SDA_io), 
    .SCL_o(SCL_o), 
    .Tx_o(Tx_o), 
    .CS_o(CS_o), 
    .Debug_o(Debug_o), 
    .Unused_o(Unused_o), 
    .X_o(X_o), 
    .Y_o(Y_o), 
    .Z_o(Z_o), 
    .Data_Available_o(Data_Available_o)
    );
	 
	 
	always
		begin
			Clk_i = 0;
			#10;
			Clk_i = 1;
			#10;
		end

	initial begin
		// Initialize Inputs
		Reset_i = 0;
		Switch_i = 0;

		// Wait 100 ns for global reset to finish
		#100;
		Reset_i = 1;
		Switch_i = 1;
 		// Add stimulus here

	end
	
	
	always @ (posedge Clk_i or negedge Reset_i)
		begin
			if(Reset_i == 1'b0)
				begin
					data_counter_r <= 3'd0;
				end
			else
				begin
					if(instance_name.IP_0.i2c_single_read.next_state_r == i2c_fsm_data_to_read_p && instance_name.IP_0.i2c_single_read.scl_fall_edge_r == 1'b1 &&  data_counter_r < 3'd7)
						begin
							data_counter_r <= data_counter_r + 1'b1;
						end
					else if(instance_name.IP_0.i2c_single_read.next_state_r == i2c_fsm_data_to_read_p && instance_name.IP_0.i2c_single_read.scl_fall_edge_r == 1'b1 &&  data_counter_r == 3'd7)
						begin
							data_counter_r <= 3'd0;
						end
					else if (instance_name.IP_0.i2c_burst_read.next_state_r == i2c_fsm_data_to_read_p && instance_name.IP_0.i2c_burst_read.scl_fall_edge_r == 1'b1 &&  data_counter_r < 3'd7)
						begin
							data_counter_r <= data_counter_r + 1'b1;
						end
					else if (instance_name.IP_0.i2c_burst_read.next_state_r == i2c_fsm_data_to_read_p && instance_name.IP_0.i2c_burst_read.scl_fall_edge_r == 1'b1 &&  data_counter_r == 3'd7)
						begin
							data_counter_r <= 3'd0;
						end
					else
						begin
							data_counter_r <= data_counter_r;
						end
				end
		end
      
		
		always @ (posedge Clk_i or negedge Reset_i)
			begin
				if(Reset_i == 1'b0)
					begin
						SDA_io <= 1'b1;
					end
				else
					begin
						if(instance_name.IP_0.i2c_single_read.next_state_r == i2c_fsm_data_to_read_p)
							begin
								SDA_io <= slave_address_p[7-data_counter_r];
							end
						else if (instance_name.IP_0.i2c_burst_read.next_state_r == i2c_fsm_data_to_read_p && instance_name.IP_0.i2c_burst_read.axes_counter_r == 3'd0)
							begin
								SDA_io <= x_axes_r[7-data_counter_r];
							end
						else if (instance_name.IP_0.i2c_burst_read.next_state_r == i2c_fsm_data_to_read_p && instance_name.IP_0.i2c_burst_read.axes_counter_r == 3'd1)
							begin
								SDA_io <= x_axes_r[8+data_counter_r];
							end
						else if (instance_name.IP_0.i2c_burst_read.next_state_r == i2c_fsm_data_to_read_p && instance_name.IP_0.i2c_burst_read.axes_counter_r == 3'd2)
							begin
								SDA_io <= y_axes_r[7-data_counter_r];
							end
						else if (instance_name.IP_0.i2c_burst_read.next_state_r == i2c_fsm_data_to_read_p && instance_name.IP_0.i2c_burst_read.axes_counter_r == 3'd3)
							begin
								SDA_io <= y_axes_r[8+data_counter_r];
							end
						else if (instance_name.IP_0.i2c_burst_read.next_state_r == i2c_fsm_data_to_read_p && instance_name.IP_0.i2c_burst_read.axes_counter_r == 3'd4)
							begin
								SDA_io <= z_axes_r[7-data_counter_r];
							end
						else if (instance_name.IP_0.i2c_burst_read.next_state_r == i2c_fsm_data_to_read_p && instance_name.IP_0.i2c_burst_read.axes_counter_r == 3'd5)
							begin
								SDA_io <= z_axes_r[8+data_counter_r];
							end
						else
							begin
								SDA_io <= 1'b1;
							end
					end
			end
			
			always @ (posedge Clk_i or negedge Reset_i)
				begin
					if(Reset_i == low_p)
						begin
							x_axes_r <= 16'd0;
							y_axes_r <= 16'd0;
							z_axes_r <= 16'd0;
						end
					else
						begin
							if(instance_name.IP_0.i2c_burst_read.next_state_r == instance_name.IP_0.i2c_burst_read.i2c_fsm_stop_p && instance_name.IP_0.i2c_burst_read.scl_active_region == high_p && instance_name.IP_0.i2c_burst_read.wait_counter_r == instance_name.IP_0.i2c_burst_read.wait_time_p && instance_name.IP_0.i2c_burst_read.single_read_frame_count_r < instance_name.IP_0.i2c_burst_read.registers_to_read_p)
								begin
									x_axes_r <= x_axes_r + 2'd1;
									y_axes_r <= y_axes_r + 2'd2;
									z_axes_r <= z_axes_r + 2'd3;
								end
							else
								begin
									x_axes_r <= x_axes_r;
									y_axes_r <= y_axes_r;
									z_axes_r <= z_axes_r;
								end
						end
				end
      
endmodule

