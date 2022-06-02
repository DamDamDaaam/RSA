`timescale 1ns / 100ps

module TestROM(
    input wire clk,
    input wire [12:0] addr,
    input wire [15:0] data
    );

    Primes_16bit_ROM rom (
        .clka(clk),
        .addra(addr),
        .douta(data)
    );

endmodule
