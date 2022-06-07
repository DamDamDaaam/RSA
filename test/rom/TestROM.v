`timescale 1ps / 1ps

module TestROM(
    input wire clk,
    input wire [12:0] addr,
    output wire [15:0] data
    );

    Primes_16bit_ROM rom (
        .clka(clk),
        .addra(addr),
        .douta(data)
    );

endmodule
