`timescale 1ns / 100ps

//Contatore che raggiunge un certo valore, genera un impulso di durata 1 ciclo di clock,
//fa rollover forzato e ricomincia

module TickCounter #(parameter integer MAX)(
    input wire clk,
    output reg tick
    );

    reg [$clog2(MAX)-1:0] count = 'b0 ;

    always @(posedge clk) begin
        if( count == MAX-1 ) begin
            count <= 'b0 ;
            tick  <= 1'b1 ;
        end
        else begin
            count <= count + 'b1 ;
            tick  <= 1'b0 ;
        end
    end

endmodule

