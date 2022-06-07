`timescale 1ns / 100ps

module LFSR32 (
    input wire clk,
    input wire rst,
    input wire en,
    input wire acquire_seed;
    input wire [31:0] seed,
    output reg [31:0] rng_out
    );
    
    reg [31:0] rng_shiftreg;
    
    //Taps: 32, 31, 29, 1
    
    always @(posedge clk) begin
        if (acquire_seed)
            rng_shiftreg <= seed;
        else begin
            rng_shiftreg[0] <= rng_shiftreg[31];
            //TODO continuare la scrittura
        end
    end

endmodule
