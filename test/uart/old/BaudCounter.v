`timescale 1ns / 100ps

module BaudCounter (
    input wire clk,
    input wire rst,
    input wire en,
    output reg [3:0] count
    );

    always @(posedge clk) begin
        if (rst)
            count <= 4'b0;
        else if (en)
            count <= count + 4'b1;
    end

endmodule
