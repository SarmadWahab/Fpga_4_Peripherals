////////////////////////////////////////////////////////////////////////////////
// Company: DIY Projects
// Engineer: Sarmad Wahab
//
// Create Date: 11.07.2021
// Design Name: Ultrasonic sensor 
// Module Name: Top module
// Target Device: Xilinx Spartan 6
// Tool versions: Design ISE 14.7
////////////////////////////////////////////////////////////////////////////////

module ultrasonic_sensor_top
  (
   Clk_i,
   Reset_i,
   Switch_i,
   Cm_or_inches_i,
   Echo_i,
   Trig_o,
   Tx_o,
   Unused_bit_o
);


   input  Clk_i, Reset_i, Switch_i, Cm_or_inches_i, Echo_i;
   output Trig_o, Tx_o, Unused_bit_o;

   wire                         trig_w;
   wire [distance_length_p  :0]  distance_w;
   wire                         data_available_w;
   wire                         distance_available_w;
   wire [data_length_p :0]      converted_distance_w;
   wire                         tx_w;
   
  
  
   ultrasonic_sensor_trigger IP_1  // This IP is responsible for generating trigger signal with 60ms time period !!!
   (   
    .Clk_i(Clk_i), 
    .Reset_i(Reset_i), 
    .Switch_i(Switch_i), 
    .Trig_o(trig_w)
    );

   ultrasonic_sensor_echo IP_2   // This IP is responsible to calculate the duty cycle of echo signal in nanoseconds (only integer calculations, for decimal please use fixed points or float point)
   (
    .Clk_i(Clk_i), 
    .Reset_i(Reset_i), 
    .Echo_i(Echo_i), 
    .cm_or_inches_i(Cm_or_inches_i), 
    .Distance_o(distance_w), 
    .Data_available_o(data_available_w)
    );

   ultrasonic_sensor_data_converter IP_3  // This is IP is used to convert the data into ASCII standards, later it can be sent on UART
   (
    .Clk_i(Clk_i), 
    .Reset_i(Reset_i), 
    .Distance_i(distance_w[uart_data_length_p:0]),  // 9 bits is enough to calculate the 400cm 
    .Distance_Available_i(data_available_w), 
    .Distance_o(converted_distance_w), 
    .Distance_Available_o(distance_available_w)
    );

   ultrasonic_sensor_uart_transmission IP_4  // This IP is responsible to transmit the ultrasonic sensor data ti UART with baud rate 9600
   (
    .Clk_i(Clk_i), 
    .Reset_i(Reset_i), 
    .Data_available_i(distance_available_w), 
    .Data_i(converted_distance_w[data_length_p:1]), // 12 bits are required
    .cm_or_inch_i(Cm_or_inches_i), 
    .Tx_o(tx_w)
    );

   assign Trig_o       = trig_w; 
   assign Tx_o         = tx_w;
   assign Unused_bit_o = (distance_w[distance_length_p : uart_data_length_p + 1] && converted_distance_w[0]) ? 1'b1: 1'b0; // Just randomly programmed bits to led to avoid warnings !!!
   
   
endmodule

   
