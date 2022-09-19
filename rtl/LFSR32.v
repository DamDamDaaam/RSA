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
    
    //Taps: 32, 31, 29, 1
    wire feedback;
    
    assign feedback = rng_out[31];
    
    always @(posedge clk) begin
        if (rst)
            rng_out <= 32'b11010100101001010110101010101101;
        else if (en) begin
            rng_out[0] <= feedback;
            for (integer i = 1; i < 28; i = i + 1)
                rng_out[i] <= rng_out[i - 1];
            rng_out[28] <= rng_out[27] ^ feedback;
            rng_out[29] <= rng_out[28];
            rng_out[30] <= rng_out[29] ^ feedback;
            rng_out[31] <= rng_out[30] ^ feedback;
        end
    end

endmodule
