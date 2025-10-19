`timescale 1ns / 1ps
module tb_elevator_controller;
    reg clk, reset;
    reg [3:0] request, floor_sensor;
    reg door_open_btn, door_close_btn, emergency_stop;
    wire [1:0] current_floor;
    wire motor_up, motor_down, door_open, emergency_led;

    elevator_controller dut (
        .clk(clk), .reset(reset),
        .request(request),
        .floor_sensor(floor_sensor),
        .door_open_btn(door_open_btn),
        .door_close_btn(door_close_btn),
        .emergency_stop(emergency_stop),
        .current_floor(current_floor),
        .motor_up(motor_up),
        .motor_down(motor_down),
        .door_open(door_open),
        .emergency_led(emergency_led)
    );
    initial clk = 0;
    always #5 clk = ~clk;
    initial begin
        reset = 1;
        request = 4'b0000;
        floor_sensor = 4'b0001; 
        door_open_btn = 0;
        door_close_btn = 0;
        emergency_stop = 0;
        #20;
        reset = 0;
        #10 request = 4'b1000;  
        #10 request = 4'b0000;  
        #50 floor_sensor = 4'b0010; 
        #50 floor_sensor = 4'b0100; 
        #50 floor_sensor = 4'b1000; 
        #20 door_open_btn = 1;
        #10 door_open_btn = 0;
        #40 door_close_btn = 1;
        #10 door_close_btn = 0;
        #60 emergency_stop = 1;
        #30 emergency_stop = 0;
        #20 request = 4'b0010;
        #10 request = 4'b0000;
        #50 floor_sensor = 4'b0100;
        #50 floor_sensor = 4'b0010; 
        #20 door_open_btn = 1;
        #10 door_open_btn = 0;
        #100 $stop;
    end
    initial begin
        $monitor("T=%0t | floor=%0d | up=%b down=%b door=%b emg=%b | req_latch=%b | sensor=%b",
                 $time, current_floor, motor_up, motor_down, door_open, emergency_led, dut.req_latch, floor_sensor);
    end
endmodule
