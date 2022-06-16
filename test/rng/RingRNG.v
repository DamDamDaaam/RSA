`timescale 1ns / 1ps

module RingRNG (
    input wire clk,
    input wire en,
    output wire [31:0] rng_out
    );
    
    wire to_be_inverted; //se questo segnale viene invertito il sistema oscilla, se no stabile
    wire [31:0] ring;    //Output del ring oscillator
    
    xor(to_be_inverted, ring[0], ring[31], ring[1]); //Primo bit del ring oscillator
    xor(ring[0], en, to_be_inverted);                //Sistema di enable: inverte se en è alto
    xor(ring[31], ring[30], ring[31], ring[0]);      //Ultimo bit del ring oscillator (feedback)
    
    genvar i;
    reg  [31:0] shuffle;  //Campionamenti dei nodi ring, usati per mischiare l'LHCA
    wire [31:0] buffed;   //Feedback con delay dall'output all'input dell'LHCA
    wire [31:0] lhca_in;  //Nodi di input dell'LHCA contenenti i risultati delle xor
    reg  [31:0] lhca_out; //Nodi di output dell'LHCA, collegati all'output del modulo
    
    assign rng_out = lhca_out;
    
    //Primo e ultimo bit dell'LHCA
    xor(lhca_in[0], shuffle[0], buffed[0], lhca_out[1]);
    xor(lhca_in[31], shuffle[31], buffed[31], lhca_out[30]);
    buf(buffed[0], lhca_out[0]);
    buf(buffed[31], lhca_out[31]);
    
    //Tutti i bit tranne il primo e l'ultimo
    (* dont_touch = "yes" *)
    generate
        for (i = 1; i < 31; i = i + 1) begin
            xor(ring[i], ring[i - 1], ring[i], ring[i + 1]);
            xor(lhca_in[i], shuffle[i], buffed[i], lhca_out[i - 1], lhca_out[i + 1]);
            buf(buffed[i], lhca_out[i]);
        end
    endgenerate
    
    //Due banchi di flip flop
    always @(posedge clk) begin
        shuffle  <= ring;
        lhca_out <= lhca_in;
    end
    
endmodule
