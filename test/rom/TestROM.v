`timescale 1ps / 1ps

module TestROM(
    input wire clk,
    input wire [12:0] addr,
    output wire [15:0] data
    );

    Primes16bit_ROM_L2 rom (
        .clka(clk),
        .addra(addr),
        .douta(data)
    );

endmodule
