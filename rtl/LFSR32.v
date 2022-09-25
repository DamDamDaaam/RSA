`timescale 1ns / 100ps

//Linear feedback shift register a 32 bit che fornisce i numeri casuali per la generazione di chiavi

//Nota: questo NON è un generatore di numeri casuali di per sè, in quanto è privo di una
//randomness source. Agisce come un contatore che enumera i valori di 32 bit in ordine sparso.
//Per generare numeri casuali si opera l'LFSR ad alta velocità (100 MHz) e si usa come randomness
//source l'istante a cui l'utente preme il pulsante start.

module LFSR32 (
    input wire clk,
    input wire rst,
    input wire en,
    output reg [31:0] rng_out
    );
    
    //Taps: 32, 12, 11, 7, 2, 1
    wire feedback;
    
    assign feedback = rng_out[0];
    
    always @(posedge clk) begin
        if (rst)
            rng_out <= 32'b11010100101001010110101010101101;
        else if (en) begin
            rng_out[31] <= feedback;
            for (integer i = 31; i > 12; i = i - 1)
                rng_out[i - 1] <= rng_out[i];
            rng_out[11] <= rng_out[12] ^ feedback;
            rng_out[10] <= rng_out[11] ^ feedback;
            for (integer i = 10; i > 7; i = i - 1)
                rng_out[i - 1] <= rng_out[i];
            rng_out[6] <= rng_out[7] ^ feedback;
            for (integer i = 6; i > 2; i = i - 1)
                rng_out[i - 1] <= rng_out[i];
            rng_out[1] <= rng_out[2] ^ feedback;
            rng_out[0] <= rng_out[1] ^ feedback;
        end
    end

endmodule
