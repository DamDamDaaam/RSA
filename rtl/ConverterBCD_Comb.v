`timescale 1ns / 100ps

//Convertitore combinatorio da binario a BCD:
//utilizza l'algoritmo shift-add-three implementando gli shift tramite moduli AddThree collegati
//a cascata

module ConverterBCD_Comb (
    input wire [31:0] bin,
    output wire [39:0] bcd
    );
    
    assign bcd[39] = 1'b0;
    assign bcd[0] = bin[0];
    
    genvar bd; //cifra BCD
    genvar si; //indice di shift
    generate
        for (bd = 1; bd < 10; bd = bd + 1) begin : b
            for (si = 3*bd; si < 32; si = si + 1) begin : s
            
                wire b1_in, b2_in, b3_in, b4_in;
                wire b1_out, b2_out, b3_out, b4_out;
                
                //Connessione di tutti gli input dei moduli AddThree
                if (si == 3*bd) begin //caso speciale: primo modulo di una riga
                    assign b4_in = 1'b0;
                    if (bd == 1) begin //caso speciale: riga più bassa
                        assign b1_in = bin[29];
                        assign b2_in = bin[30];
                        assign b3_in = bin[31];
                    end
                    else begin //qualsiasi altra riga
                        assign b1_in = b[bd - 1].s[si - 1].b4_out;
                        assign b2_in = b[bd - 1].s[si - 2].b4_out;
                        assign b3_in = b[bd - 1].s[si - 3].b4_out;
                    end
                end
                else begin //qualsiasi altro modulo di una riga
                    assign b2_in = b[bd].s[si - 1].b1_out;
                    assign b3_in = b[bd].s[si - 1].b2_out;
                    assign b4_in = b[bd].s[si - 1].b3_out;
                    if (bd == 1) begin //caso speciale: riga più bassa
                        assign b1_in = bin[32 - si];
                    end
                    else
                        assign b1_in = b[bd - 1].s[si - 1].b4_out; //qualsiasi altra riga
                end
                
                //Connessione degli output degli ultimi moduli di tutte le righe agli output
                //del converter
                if (si == 31) begin
                    assign bcd[4*bd - 3] = b1_out;
                    assign bcd[4*bd - 2] = b2_out;
                    assign bcd[4*bd - 1] = b3_out;
                    assign bcd[4*bd    ] = b4_out;
                end
                
                //Istanza del modulo AddThree
                AddThree inst (
                    .in({b4_in, b3_in, b2_in, b1_in}),
                    .out({b4_out, b3_out, b2_out, b1_out})
                );
                
            end
        end
    endgenerate
    
    assign bcd[37] = b[9].s[30].b4_out; //Questi output del converter erano stati lasciati
    assign bcd[38] = b[9].s[29].b4_out; //scollegati nel loop
    
endmodule
