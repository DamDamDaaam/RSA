`timescale 1ns / 1ps

module tb_RingRNG;

    reg clk = 1'b0;
    reg en = 1'b0;
    wire [31:0] rng;
    
    RingRNG DUT (
        .clk(clk),
        .en(en),
        .rng_out(rng)
    );
    
    reg [31:0] node;
    assign DUT.ring = node;
    
    initial begin
        node = 32'b0;
        #10 en = 1'b1;
        #100 $finish;
    end
    
endmodule
