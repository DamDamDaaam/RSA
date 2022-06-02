`timescale 1ns / 100ps

module tb_ROM;

    reg clk = 1'b0;
    reg [12:0] addr = 13'b0;
    wire data;

    TestROM DUT (
        .clk  (clk),
        .addr (addr),
        .data (data)
    );

    initial begin
        forever #5 clk = ~clk;
    end

    always @(negedge clk) begin
        addr = addr + 13'b1;
    end
    
    initial begin
        #1000 $finish;
    end

endmodule
