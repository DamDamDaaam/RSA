`timescale 1ns / 100ps

//ROM contenente tutti i numeri primi di 16 bit e successivamente riempita fino a 8 kB
//con duplicati dei numeri primi più grandi (in modo che gli indirizzi casuali di 13 bit
//siano sempre validi)

module Primes16BitROM(
        input wire clk,
        input wire [12:0] addr,
        output reg [15:0] data
    );
    
    (* rom_style = "block" *)
    reg [15:0] mem [8191:0];
    
    initial begin
        data <= 16'b0;
    end
    
    always @(posedge clk) begin
        data <= mem[addr];
    end
    
    initial begin
        $readmemh("/home/michele/rsa/bin/primes_16bit.hex", mem);
    end

endmodule
