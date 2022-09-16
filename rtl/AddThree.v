`timescale 1ns / 100ps

//Modulo per la conversione da binario a BCD:
//se l'ingresso è maggiore o uguale a 5 aggiunge 3, altrimenti copia l'ingresso

module AddThree (
    input wire [3:0] in,
    output reg [3:0] out
    );
    
    always @(*) begin
        if (in >= 4'h5)
            out = in + 4'h3;    
        else
            out = in;
    end
    
endmodule
