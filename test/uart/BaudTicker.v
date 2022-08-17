`timescale 1ns / 100ps

module BaudTicker
    #(
    parameter integer BAUD_RATE,
    parameter real CLOCK_FREQ
    )(
    input wire clk,
    input wire rst,
    output reg tick
    );

    parameter integer clk_per_baud = CLOCK_FREQ / (16.0 * BAUD_RATE);
    
    reg [$clog2(clk_per_baud) - 1 : 0] bt_counter = 'b0;
    
    always @(posedge clk) begin
        if (rst) begin
            bt_counter <= 'b0;
            tick <= 1'b0;
        end
        else if (bt_counter == clk_per_baud - 1) begin
            bt_counter <= 'b0;
            tick <= 1'b1;
        end
        else begin
            bt_counter <= bt_counter + 'b1;
            tick <= 1'b0;
        end
    end
    
endmodule
