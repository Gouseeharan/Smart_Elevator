`timescale 1ns / 1ps
module elevator_controller (
    input  clk,
    input  reset,               
    input  [3:0] request,         
    input  [3:0] floor_sensor,    
    input  door_open_btn,          
    input  door_close_btn,         
    input  emergency_stop,         

    output reg [1:0] current_floor,
    output reg motor_up,
    output reg motor_down,
    output reg door_open,
    output reg emergency_led
);

reg [3:0] req_latch;
reg any_above, any_below;
integer i;
always @(posedge clk or posedge reset) begin
    if (reset)
        req_latch <= 4'b0000;
    else
        req_latch <= req_latch | request;
end
always @(posedge clk or posedge reset) begin
    if (reset)
        current_floor <= 2'd0;
    else begin
        case (floor_sensor)
            4'b0001: current_floor <= 2'd0;
            4'b0010: current_floor <= 2'd1;
            4'b0100: current_floor <= 2'd2;
            4'b1000: current_floor <= 2'd3;
            default: current_floor <= current_floor; 
        endcase
    end
end
always @(*) begin
    any_above = 1'b0;
    any_below = 1'b0;
    for (i = 0; i < 4; i = i + 1) begin
        if (i > current_floor)
            any_above = any_above | req_latch[i];
        if (i < current_floor)
            any_below = any_below | req_latch[i];
    end
end
always @(posedge clk or posedge reset) begin
    if (reset) begin
        motor_up <= 1'b0;
        motor_down <= 1'b0;
        door_open <= 1'b0;
        emergency_led <= 1'b0;
    end
    else if (emergency_stop) begin
        motor_up <= 1'b0;
        motor_down <= 1'b0;
        door_open <= 1'b1;
        emergency_led <= 1'b1;
    end
    else begin
        emergency_led <= 1'b0;
        if ((floor_sensor[current_floor]) && req_latch[current_floor]) begin
            motor_up <= 1'b0;
            motor_down <= 1'b0;
            door_open <= 1'b1;
            req_latch <= req_latch & ~(4'b0001 << current_floor);
        end
        else if (any_above) begin
            motor_up <= 1'b1;
            motor_down <= 1'b0;
            door_open <= 1'b0;
        end
        else if (any_below) begin
            motor_up <= 1'b0;
            motor_down <= 1'b1;
            door_open <= 1'b0;
        end
        else begin
            motor_up <= 1'b0;
            motor_down <= 1'b0;
            door_open <= 1'b0;
        end
        if (door_open_btn)
            door_open <= 1'b1;
        if (door_close_btn)
            door_open <= 1'b0;
    end
end
endmodule
