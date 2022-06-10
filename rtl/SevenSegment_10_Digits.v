
// modulo di interfaccia con i SevenSegment

`timescale 1ns / 100ps
    
module SevenSegment_12_Digits (
    
    input  wire clk,
    input  wire en,
    input  wire [ 3:0] mode,    // input della mode da stampare a video
    input  wire [39:0] BCD,     // input del numero da stampare a video

    output wire segA,
    output wire segB,
    output wire segC,
    output wire segD,
    output wire segE,
    output wire segF,
    output wire segG,
    output wire DP,
    output reg [11:0] anode 
    
    ) ;
    
    initial begin
        assign segA = 1'b0;
        assign segB = 1'b0;
        assign segC = 1'b0;
        assign segD = 1'b0;
        assign segE = 1'b0;
        assign segF = 1'b0;
        assign segG = 1'b0;
        assign DP   = 1'b0;
        
        assign anode = 12'hfff;
    end


    reg [24:0] count = 'b0 ;
    
    always @(posedge clk) begin
        count <= count + 'b1 ;
    end
    
    wire [3:0] refresh_slice ;
    
    assign refresh_slice = count[20:17] ;
        
    reg [3:0] BCD_mux;
    
    always @(*) begin
    
        case( refresh_slice[3:0] )
    
            4'd0    : BCD_mux = BCD[ 3: 0] ;
            4'd1    : BCD_mux = BCD[ 7: 4] ;
            4'd2    : BCD_mux = BCD[11: 8] ;
            4'd3    : BCD_mux = BCD[15:12] ;
            4'd4    : BCD_mux = BCD[19:16] ;
            4'd5    : BCD_mux = BCD[23:20] ;
            4'd6    : BCD_mux = BCD[27:24] ;
            4'd7    : BCD_mux = BCD[31:28] ;
            4'd8    : BCD_mux = BCD[35:32] ;
            4'd9    : BCD_mux = BCD[39:36] ;
            4'd10   : BCD_mux =       4'ha ;        // stampa "-"
            4'd11   : BCD_mux =  mode[3:0] ;        // stampa il carattere di mode
            
            default : BCD_mux =        4'ha;        // stampa "-"

        endcase
    end   // always
    
    integer i ;

    wire d_point;
    
    always @(*) begin
    
        for (i=0 ; i<12; i=i+1) begin
    
            anode[i] = ( refresh_slice == i ) ;
            if(i>9)
                assign d_point = 1'b0;
            else
                assign d_point = 1'b1;
    
        end  // for
    end  // always    
        
    SevenSegmentDecoder  display_decoder (
    
        .BCD   (   BCD_mux ),
        .dp    (   d_point ),
        .segA  (      segA ),
        .segB  (      segB ),
        .segC  (      segC ),
        .segD  (      segD ),
        .segE  (      segE ),
        .segF  (      segF ),
        .segG  (      segG ),
        .DP    (        DP )
    
    ) ;
    
endmodule
