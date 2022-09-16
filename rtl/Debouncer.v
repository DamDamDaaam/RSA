`timescale 1ns / 100ps

//Debouncer ispirato al modello visto in aula, ma modificato per generare un impulso di
//durata pari a un singolo ciclo di clock

module Debouncer (
   input wire clk,
   input wire button,         // Input sporco da pulsante
   output reg pulse           // Impulso pulito di durata 1 clk
   ) ;

   ////////////////////////////////////////
   //   low-frequency 'tick' generator   //
   ////////////////////////////////////////

   wire enable ;

   TickCounter #(.MAX(5000001)) TickCounter_inst (.clk(clk), .tick(enable)) ;   // 20 Hz clock-enable
//   TickCounter #(.MAX(13)) TickCounter_inst (.clk(clk), .tick(enable)) ;   // 7.6 MHz clock-enable (for simulation purpose)

   ////////////////////////////////
   //   single-pulse generator   // tick length = period of TickCounter
   ////////////////////////////////

   reg [1:0] q1 = 'b0 ;   // 2 FlipFlops

   always @(posedge clk) begin
      
      pulse <= 1'b0;
      
      if(enable) begin
         q1[0] <= button ;
         q1[1] <= q1[0] ;
      end
      
      if (q1[0] & (~q1[1])) begin
         q1[1] <= 1'b1;
         pulse <= 1'b1;
      end
   end

endmodule

