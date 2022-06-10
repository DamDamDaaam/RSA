//
// Binary-Coded Decimal (BCD) counter with count-enable and carry flag.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2020
//

`timescale 1ns / 100ps

module CounterBCD (
    
    input  wire clk,
    input  wire rst,
    input  wire  en,
    output reg [3:0] BCD,
    output wire carryout
    
    ) ;
    
    
    always @(posedge clk or posedge rst) begin       // asynchronous reset
    //always @(posedge clk) begin                        // synchronous reset
    
        if( rst == 1'b1 )
            BCD <= 4'b0000 ;            // here you can also use 4'd0 or 'd0
    
        else begin
    
            if( en == 1'b1 ) begin      // let the counter to increment only if enabled (same as 'if(en)' for less typing)
    
                if( BCD == 4'b1001 )     // force the count roll-over at 9 (you can also use 4'd9)
                    BCD <= 4'b0000 ;
                else
                    BCD <= BCD + 4'b1 ;
            end
            //else ? keep memory otherwise
        end
    end // always
    
    
    assign carryout = ( (BCD == 4'b1001) && (en == 1'b1) ) ? 1'b1 : 1'b0 ;
    
endmodule
    
    
//
// Parameterized N-digit BCD counter. The logic includes an end-of-scale flag
// asserted when 9999 ... 9 is reached and an overflow flag when the count goes
// out of range.
//
// Luca Pacher - pacher@to.infn.it
// Spring 2020
//


`timescale 1ns / 100ps

module CounterBCD_Ndigit #(parameter integer NDIGITS = 10) (
    
    input  wire clk,
    input  wire rst,
    input  wire en,
    output wire [NDIGITS*4-1:0] BCD,
    output wire overflow,               // asserted when the most-significant digit generates a carry
    output wire eos                     // asserted when 9999 ... 9 is reached
    
    ) ;
    
    
    
    /////////////////////////////
    //   N-digit BCD counter   //
    /////////////////////////////
    
    
    wire [NDIGITS:0] w ;   // NDIGITS + 1 wires to interconnect BCD counters each other
    
    assign w[0] = en ;
    
    generate
    
        genvar k ;
    
        for(k = 0; k < NDIGITS; k = k+1) begin : digit  
    
            CounterBCD  digit (
    
                .clk      (                 clk ),
                .rst      (                 rst ),
                .en       (                w[k] ),
                .BCD      (      BCD[4*k+3:4*k] ),
                .carryout (              w[k+1] )
    
            ) ;
    
        end // for
    
    endgenerate
    
    
    // generate end-of-scale flag when 9999 ... 9 is reached
    assign eos = ( BCD == {NDIGITS{4'b1001}} ) ? 1'b1 : 1'b0 ;      // use the Verilog replication operator to replicate 4'1001 NDIGITS times
    
    // generate overflow flag
    assign overflow = w[NDIGITS] ;    // simply the carry-out of the most-significant BCD counter
    
endmodule
    