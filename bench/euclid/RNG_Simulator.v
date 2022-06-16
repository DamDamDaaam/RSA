`timescale 1ns / 100ps

module RNG_Simulator(
    input wire clk,
    input wire rst,
    input wire en,
    output reg [31:0] rng_out
    );
    
    reg [31:0] rng;
    
    initial begin
        $srandom(7823);
        rng_out <= $urandom_range(32'b1, 32'd4157295845);
    end
    
    always @(posedge clk) begin
        if (rst) rng_out <= 32'b0;
        else if (en) rng_out <= $urandom_range(32'b1, 32'd4157295845); //Generate less than phi
    end

endmodule
