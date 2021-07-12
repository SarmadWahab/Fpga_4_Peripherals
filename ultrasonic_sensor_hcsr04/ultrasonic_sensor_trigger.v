////////////////////////////////////////////////////////////////////////////////
// Company: DIY Projects
// Engineer: Sarmad Wahab
//
// Create Date: 11.07.2021
// Design Name: Ultrasonic Sensor
// Module Name: trigger module
// Target Device: Xilinx Spartan 6
// Tool versions: Design ISE 14.7
////////////////////////////////////////////////////////////////////////////////
`include "give_your_local_location\hcsr04_parameters.v"

module ultrasonic_sensor_trigger 
  (Clk_i,
   Reset_i,
   Switch_i,
   Trig_o
   );

  
   input Clk_i,Reset_i,Switch_i;
   output Trig_o;
   

   reg [ultrasonic_sensor_trigger_counter_p-1 : 0] ultrasonic_counter_r;
   reg                                             trig_r;



   always @ (posedge Clk_i or negedge Reset_i)   //This modules generates time period of 60ms
     begin
	if(Reset_i == low_p)
	  begin
	     ultrasonic_counter_r <= low_p;
	  end
	else
	  begin
	     if(Switch_i == high_p && ultrasonic_counter_r < ultrasonic_sensor_time_period_p)
	       begin
		  ultrasonic_counter_r <= ultrasonic_counter_r + single_bit_p;
	       end
	     else
	       begin
		  ultrasonic_counter_r <= low_p;
	       end
	  end
     end 

   

   always @ (posedge Clk_i or negedge Reset_i)  // This modules generate 10us duty cycles
     begin
	if(Reset_i == low_p)
	  begin
	     trig_r <= low_p;
	  end
	else
	  begin
	     if(ultrasonic_counter_r < trigger_duty_clock_cycles_p && Switch_i == high_p)
	       begin
		  trig_r <= high_p;
	       end
	     else
	       begin
		  trig_r <= low_p;
	       end
	  end
     end

   
   
   assign Trig_o = trig_r;
    

   

   
endmodule
