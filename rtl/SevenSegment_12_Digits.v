`timescale 1ns / 100ps

//Modulo di interfaccia con il display Seven Segment a 12 cifre.
//La prima cifra indica la mode (o l'operazione in corso), la seconda è un separatore,
//le successive rappresentano una delle chiavi, a seconda della mode

//Il punto è separatore delle migliaia, tranne nella modalità di editing, in cui il
//punto lampeggiante funge da cursore

module SevenSegment_12_Digits (
    
    input  wire clk,
    input  wire en,             // non un vero e proprio enable, ma stampa trattini se busy
    input  wire [ 3:0] mode,    // input della mode da stampare a video
    input  wire [39:0] BCD,     // input del numero da stampare a video
    
    input  wire typing,
    input  wire [ 3:0] digit,

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
    
    reg [25:0] count = 'b0 ;
    
    always @(posedge clk) begin
        count <= count + 'b1 ;
    end
    
    wire [3:0] refresh_slice;
    assign refresh_slice = count[20:17];
        
    reg [3:0] BCD_mux;
    reg d_point;
    wire blink;
    assign blink = count[25];
    
    always @(*) begin
        if(en) begin
            case( refresh_slice[3:0] )
        
                4'd0    : begin
                    BCD_mux = BCD[ 3: 0] ;                  //seleziona la cifra da BCD.
                    if(typing)                              //se si sta editando...
                        if(refresh_slice == digit && blink) //...se questa è la cifra editata...
                            d_point = 1'b0;                 //
                        else                                //...fai lampeggiare il punto...
                            d_point = 1'b1;                 //
                    else
                        d_point = 1'b1;                     //...altrimenti spegnilo
                    end
                4'd1    : begin
                    BCD_mux = BCD[ 7: 4] ;
                    if(typing)
                        if(refresh_slice == digit && blink)
                            d_point = 1'b0;
                        else
                            d_point = 1'b1;
                    else
                        d_point = 1'b1;
                    end
                4'd2    : begin
                    BCD_mux = BCD[11: 8] ;
                    if(typing)
                        if(refresh_slice == digit && blink)
                            d_point = 1'b0;
                        else
                            d_point = 1'b1;
                    else
                        d_point = 1'b1;
                    end
                4'd3    : begin
                    BCD_mux = BCD[15:12] ;
                    if(typing)
                        if(refresh_slice == digit && blink)
                            d_point = 1'b0;
                        else
                            d_point = 1'b1;
                    else
                        d_point = 1'b0;                       //migliaia, quindi punto acceso
                    end
                4'd4    : begin
                    BCD_mux = BCD[19:16] ;
                    if(typing)
                        if(refresh_slice == digit && blink)
                            d_point = 1'b0;
                        else
                            d_point = 1'b1;
                    else
                        d_point = 1'b1;
                    end
                4'd5    : begin
                    BCD_mux = BCD[23:20] ;
                    if(typing)
                        if(refresh_slice == digit && blink)
                            d_point = 1'b0;
                        else
                            d_point = 1'b1;
                    else
                        d_point = 1'b1;
                    end
                4'd6    : begin
                    BCD_mux = BCD[27:24] ;
                    if(typing)
                        if(refresh_slice == digit && blink)
                            d_point = 1'b0;
                        else
                            d_point = 1'b1;
                    else
                        d_point = 1'b0;                      //milioni, punto acceso
                    end
                4'd7    : begin
                    BCD_mux = BCD[31:28] ;
                    if(typing)
                        if(refresh_slice == digit && blink)
                            d_point = 1'b0;
                        else
                            d_point = 1'b1;
                    else
                        d_point = 1'b1;
                    end
                4'd8    : begin
                    BCD_mux = BCD[35:32] ;
                    if(typing)
                        if(refresh_slice == digit && blink)
                            d_point = 1'b0;
                        else
                            d_point = 1'b1;
                    else
                        d_point = 1'b1;
                    end
                4'd9    : begin
                    BCD_mux = BCD[39:36] ;
                    if(typing)
                        if(refresh_slice == digit && blink)
                            d_point = 1'b0;
                        else
                            d_point = 1'b1;
                    else
                        d_point = 1'b0;                       //miliardi, punto acceso
                    end
                4'd10   : begin
                    BCD_mux =       4'ha ;          // stampa "-"
                    d_point = 1'b1;
                    end
                4'd11   : begin
                    BCD_mux =  mode[3:0] ;          // stampa il carattere di mode
                    d_point = 1'b0;
                    end
                
                default : begin
                    BCD_mux = 4'ha;                 // stampa "-"
                    d_point = 1'b1;
                    end
    
            endcase
        end
        else begin                                  //se il dispositivo è busy (en basso)
            case( refresh_slice[3:0] )
                4'd11   : begin
                    BCD_mux =  mode[3:0] ;          // stampa il carattere di mode
                    d_point = 1'b0;
                    end
                
                default : begin
                    BCD_mux = 4'ha;                 // stampa "-"
                    d_point = 1'b1;
                    end
    
            endcase
        end
    end   // always
    
    integer i ;
    
    //bin to one-hot per pilotare gli anodi
    
    always @(*) begin
        for (i=0 ; i<12; i=i+1) begin
            anode[i] = ( refresh_slice == i ) ;
        end
    end
        
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
