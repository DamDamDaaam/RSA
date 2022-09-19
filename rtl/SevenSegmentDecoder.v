`timescale 1ns / 100ps

//Decoder che associa i valori BCD ai segmenti da accendere e spegnere

module SevenSegmentDecoder (

    input wire [3:0] BCD,
    input wire dp,

    output reg segA,
    output reg segB,
    output reg segC,
    output reg segD,
    output reg segE,
    output reg segF,
    output reg segG,
    output wire DP
    
    ) ;
    
    assign DP = dp;
    
    always @(*) begin
    
        case( BCD[3:0] )
                                                                 //  abcdefg
            4'h0  :  {segA, segB, segC, segD, segE, segF, segG} = 7'b0000001 ;  //  0
            4'h1  :  {segA, segB, segC, segD, segE, segF, segG} = 7'b1001111 ;  //  1
            4'h2  :  {segA, segB, segC, segD, segE, segF, segG} = 7'b0010010 ;  //  2
            4'h3  :  {segA, segB, segC, segD, segE, segF, segG} = 7'b0000110 ;  //  3
            4'h4  :  {segA, segB, segC, segD, segE, segF, segG} = 7'b1001100 ;  //  4
            4'h5  :  {segA, segB, segC, segD, segE, segF, segG} = 7'b0100100 ;  //  5 o S (Searching key)
            4'h6  :  {segA, segB, segC, segD, segE, segF, segG} = 7'b0100000 ;  //  6
            4'h7  :  {segA, segB, segC, segD, segE, segF, segG} = 7'b0001111 ;  //  7
            4'h8  :  {segA, segB, segC, segD, segE, segF, segG} = 7'b0000000 ;  //  8
            4'h9  :  {segA, segB, segC, segD, segE, segF, segG} = 7'b0000100 ;  //  9
                                                                
            4'ha  :  {segA, segB, segC, segD, segE, segF, segG} = 7'b1111110 ;  //  -
                                                                
            4'hb  :  {segA, segB, segC, segD, segE, segF, segG} = 7'b1101010 ;  //  n (n key)
            4'hc  :  {segA, segB, segC, segD, segE, segF, segG} = 7'b0110001 ;  //  C (Crypting)
            4'hd  :  {segA, segB, segC, segD, segE, segF, segG} = 7'b1000010 ;  //  d (d key)
            4'he  :  {segA, segB, segC, segD, segE, segF, segG} = 7'b0110000 ;  //  E (e key)
            4'hf  :  {segA, segB, segC, segD, segE, segF, segG} = 7'b1000001 ;  //  U (Uncrypting)
            
        endcase
    end

endmodule
