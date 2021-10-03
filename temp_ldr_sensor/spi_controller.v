`include "give_your_local_location\Tmp_LDR_parameters.v"

////////////////////////////////////////////////////////////////////////////////
// Company:        DIY Projects 
// Engineer:       Sarmad Wahab 
// Create Date:    19:09:41 09/19/2021 
// Design Name:    Temperature & LDR sensor
// Module Name:    spi_controller
// Target Devices: Xilinx Spartan 6
// Tool versions:  Design ISE 14.7
////////////////////////////////////////////////////////////////////////////////

module spi_controller
  (
   Clk_i,
   Reset_i,
   Switch_i,
   Temp_LDR_i,
   MISO_i,
   CS_o,
   SCLK_o,
   MOSI_o,
   Data_Available_o,
   Data_o
);
   
   parameter data_length_p              = 4'hD;
   parameter spi_fsm_length_p           = 2'd3;
  
  

   input  Clk_i, Reset_i, Switch_i, MISO_i,Temp_LDR_i;
   output CS_o, SCLK_o, MOSI_o, Data_Available_o;
   output [data_length_p - high_p-high_p : 0] Data_o;


   reg 					      sclk_r;
   reg 					      start_sclk_r;
   reg 					      delay_sclk_r;
   reg 					      sclk_fall_edge_r;
   reg 					      sclk_active_region_r;
   reg 					      cs_r;
   reg 					      mosi_r;
   reg 					      data_available_r;
   
 
   reg [spi_fsm_length_p            : 0] next_state_r;
   reg [spi_internal_counter_p      : 0] spi_internal_counter_r;
   reg [spi_timer_period_counter_p  : 0] spi_time_period_counter_r;
   reg [spi_counter_length_p        : 0] spi_channel_information_r;
   reg [data_length_p-high_p-high_p : 0] data_r;
   
   

   
 always @ (posedge Clk_i)  // SPI time period counter
   begin
      if(Reset_i == low_p)
	begin
	   spi_time_period_counter_r <= {4'hF,4'hF,high_p,high_p}; 
	end
      else
	begin
	   if(start_sclk_r == high_p && spi_time_period_counter_r < spi_time_period_p)
	     begin
		spi_time_period_counter_r <= spi_time_period_counter_r + high_p;
	     end
	   else
	     begin
		spi_time_period_counter_r <= zero_p;
	     end
	end
   end


   always @ (posedge Clk_i or negedge Reset_i)  // SPI Clock @ 1MHz
     begin
	if(Reset_i == low_p)
	  begin
	     sclk_r <= low_p;
	  end
	else
	  begin
	     if(spi_time_period_counter_r < spi_time_period_half_p)
	       begin
		  sclk_r <= low_p;
	       end
	     else
	       begin
		  sclk_r <= high_p;
	       end
	  end
     end

   always @ (posedge Clk_i or negedge Reset_i)  // Delay SCLK one clock cycle
     begin
	if(Reset_i == low_p)
	  begin
	     delay_sclk_r <= low_p;
	  end
	else
	  begin
	     delay_sclk_r <= sclk_r;
	  end
     end 

   always @ (posedge Clk_i or negedge Reset_i)  // Fall edge of SPI clock 
     begin
	if(Reset_i == low_p)
	  begin
	     sclk_fall_edge_r <= low_p;
	  end
	else
	  begin
	     if(delay_sclk_r == high_p && sclk_r == low_p)
	       begin
		  sclk_fall_edge_r <= high_p;
	       end
	     else
	       begin
		  sclk_fall_edge_r <= low_p;
	       end
	  end
     end

   always @ (posedge Clk_i or negedge Reset_i)  // Channel information !!!
     begin
	if(Reset_i == low_p)
	  begin
	     spi_channel_information_r <= zero_p;
	  end
	else
	  begin
	     if(Temp_LDR_i == high_p)
	       begin
		  spi_channel_information_r <= {high_p,high_p,high_p,high_p};  // Channel 7 with Single Ended 
	       end
	     else
	       begin
		  spi_channel_information_r <= {low_p,high_p,high_p,high_p};   // Channel 6 with Single Ended
	       end
	  end
     end

   always @ (posedge Clk_i or negedge Reset_i)  // Read data from MISO line
     begin
	if(Reset_i == low_p)
	  begin
	     data_r <= 12'h000;
	  end
	else
	  begin
	     if(next_state_r == spi_fsm_read_data_p && spi_internal_counter_r > low_p)  // First two cycles are empty and null values
	       begin
		  data_r[12-spi_internal_counter_r] <= MISO_i;
	       end
	     else
	       begin
		  data_r <= data_r;
	       end
	  end
     end
   
   always @ (posedge Clk_i or negedge Reset_i)  // FSM for SPI 
     begin
	if(Reset_i == low_p)
	  begin
	     next_state_r           <= spi_fsm_idle_p;
	     cs_r                   <= high_p;
	     mosi_r                 <= high_p;
	     start_sclk_r           <= low_p;
	     data_available_r       <= low_p;
	     spi_internal_counter_r <= {4'hF,4'hF,4'hF};
	  end
	else
	  begin
	     case(next_state_r)
	       spi_fsm_idle_p:
		 begin
		    if(Switch_i == high_p)
		      begin
			 next_state_r <= spi_fsm_start_p;
			 cs_r         <= low_p;
			 start_sclk_r <= high_p;
		      end
		    else
		      begin
			 next_state_r <= spi_fsm_idle_p;
			 cs_r         <= high_p;
			 start_sclk_r <= low_p;
		      end
		    mosi_r                 <= high_p;
		    data_available_r       <= low_p;
		    spi_internal_counter_r <= zero_p;
		 end
	       spi_fsm_start_p:
		 begin
		    if(sclk_fall_edge_r == high_p)
		      begin
			 next_state_r <= spi_fsm_channel_p;
			 mosi_r       <= spi_channel_information_r[spi_internal_counter_r];
		      end
		    else
		      begin
			 next_state_r <= next_state_r;
			 mosi_r       <= mosi_r;
		      end
		    cs_r                   <= cs_r;
		    start_sclk_r           <= start_sclk_r;
		    data_available_r       <= data_available_r;
		    spi_internal_counter_r <= spi_internal_counter_r;
		 end
	       spi_fsm_channel_p:
		 begin
		    if(sclk_fall_edge_r == high_p && spi_internal_counter_r < spi_counter_length_p)
		      begin
			 next_state_r           <= next_state_r;
			 spi_internal_counter_r <= spi_internal_counter_r + high_p;
		      end
		    else if (sclk_fall_edge_r == high_p && spi_internal_counter_r == spi_counter_length_p)
		      begin
			 next_state_r           <= spi_fsm_read_data_p;
			 spi_internal_counter_r <= zero_p;
		      end
		    else
		      begin
			 next_state_r           <= next_state_r;	
			 mosi_r                 <= spi_channel_information_r[spi_internal_counter_r];
			 spi_internal_counter_r <= spi_internal_counter_r;
		      end
		    cs_r             <= cs_r;
		    start_sclk_r     <= start_sclk_r;
		    data_available_r <= data_available_r;
		    mosi_r           <= spi_channel_information_r[spi_internal_counter_r];
		 end
	       spi_fsm_read_data_p:
		 begin
		    if(sclk_fall_edge_r == high_p && spi_internal_counter_r < data_length_p - high_p)
		      begin
			 next_state_r           <= next_state_r;
			 cs_r                   <= cs_r;
			 spi_internal_counter_r <= spi_internal_counter_r + high_p;
		      end
		    else if (sclk_fall_edge_r == high_p && spi_internal_counter_r == data_length_p - high_p)
		      begin
			 next_state_r           <= spi_fsm_stop_p;
			 cs_r                   <= high_p;
			 spi_internal_counter_r <= zero_p;
		      end
		    else
		      begin
			 next_state_r           <= next_state_r;
			 cs_r                   <= cs_r;
			 spi_internal_counter_r <= spi_internal_counter_r;
		      end
		    mosi_r           <= mosi_r;
		    start_sclk_r     <= start_sclk_r;
		    data_available_r <= data_available_r;
		 end
	       spi_fsm_stop_p:
		 begin
		    if(sclk_fall_edge_r == high_p && spi_internal_counter_r == freeze_time_p)
		      begin
			 next_state_r     <= spi_fsm_idle_p;
			 data_available_r <= high_p;
			 spi_internal_counter_r <= zero_p;
		      end
		    else if (sclk_fall_edge_r == high_p && spi_internal_counter_r < freeze_time_p)
		      begin
			 next_state_r     <= next_state_r;
			 data_available_r <= data_available_r;
			 spi_internal_counter_r <= spi_internal_counter_r + high_p;
		      end
		    else
		      begin
			 next_state_r     <= next_state_r;
			 data_available_r <= data_available_r;
			 spi_internal_counter_r <= spi_internal_counter_r;
		      end
		    cs_r         <= cs_r;
		    mosi_r       <= mosi_r;
		    start_sclk_r <= start_sclk_r;
		 end
	       default:
		 begin
		    next_state_r <= spi_fsm_idle_p;
		    cs_r         <= high_p;
		    start_sclk_r <= low_p;
		 end		 
	     endcase
	  end
     end
  
   assign Data_o           = data_r;
   assign Data_Available_o = data_available_r;
   assign MOSI_o           = mosi_r;
   assign CS_o             = cs_r;
   assign SCLK_o           = sclk_r;
   
   
endmodule
