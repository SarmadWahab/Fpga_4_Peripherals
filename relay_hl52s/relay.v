module relay
   (
    Clk_i,
    Reset_i,
    Switch_i,
    Relay_o
);


   input  Clk_i,Reset_i,Switch_i;
   output Relay_o;

   reg [counter_length_p-1 : 0] counter_r;
   reg                          delay_switch_r;
   reg                          relay_r;
   
   
   


   always @ (posedge Clk_i or Reset_i)  // This block is used to delay input one clock cycle !!!
     begin
	if(Reset_i == low_p)
	  begin
	     delay_switch_r <= low_p;
	  end
	else
	  begin
	     delay_switch_r <= Switch_i; 
	  end
     end 

   

   always @ (posedge Clk_i or Reset_i)  // This is to make sure input is stable for mentioned number of clock cycles 
     begin
	if(Reset_i == low_p)
	  begin
	     counter_r <= low_p;
	  end
	else
	  begin
	     if(delay_switch_r == Switch_i && counter_r < clock_cycles_p)
	       begin
		  counter_r <= counter_r + single_bit_p;
	       end
	     else if (delay_switch_r == Switch_i && counter_r == clock_cycles_p)
	       begin
		  counter_r <= counter_r;
	       end
	     else
	       begin
		  counter_r <= low_p;
	       end
	  end
     end

   
   always @ (posedge Clk_i or Reset_i) // Activate relay once input is stable !!!
     begin
	if(Reset_i == low_p)
	  begin
	     relay_r <= low_p;	     
	  end
	else
	  begin
	     if(counter_r == clock_cycles_p)
	       begin
		  relay_r <= high_p;
		  
	       end
	     else
	       begin
		 relay_r  <= low_p;	  
	       end
	  end
     end

   assign Relay_o = relay_r;
   
 
   

endmodule //
