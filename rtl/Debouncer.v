//
// Simple push-button debouncer with 0.5 kHz or 1 kHz low sampling frequency.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2021
//


`timescale 1ns / 100ps

module Debouncer (

   input  wire clk,            // assume 100 MHz clock frequency from on-board oscillator
   input  wire button,         // glitching push-button input
   output wire pulse           // clean single-pulse output

   ) ;


   ////////////////////////////////////////
   //   low-frequency 'tick' generator   //
   ////////////////////////////////////////

   wire enable ;

   TickCounter #(.MAX(1000001)) TickCounter_inst (.clk(clk), .tick(enable)) ;   // 0.5 kHz clock-enable
//   TickCounter #(.MAX(13)) TickCounter_inst (.clk(clk), .tick(enable)) ;   // 100 MHz clock-enable (for simulation purpose)


   ////////////////////////////////
   //   single-pulse generator   // tick length = period of TickCounter
   ////////////////////////////////

   reg [2:0] q1 = 'b0 ;   // 3 FlipFlops

   always @(posedge clk) begin

      if(enable) begin
         q1[0] <= button ;
         q1[1] <= q1[0] ;
         q1[2] <= q1[0] & (~q1[1]) ;
      end
   end
   
   ////////////////////////////////
   //   single-pulse generator   // tick length = period of clk
   ////////////////////////////////

   reg [2:0] q2 = 'b0 ;   // 3 FlipFlops

   always @(posedge clk) begin
      q2[0] <= q1[2] ;
      q2[1] <= q2[0] ;
      q2[2] <= q2[0] & (~q2[1]) ;
   end

   assign pulse = q2[2] ;

endmodule

