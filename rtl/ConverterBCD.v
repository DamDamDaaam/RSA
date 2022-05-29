
`timescale 1ns / 100ps

module ConverterBCD #(parameter integer BIN_BIT=32) (
    
    input  wire [BIN_BIT-1:0] bin_val,
    output wire [11:0] BCD_val
    
    );
    
    
    
endmodule



// PER I PRIMI DA CONTROLLARE SOLO 6*N +- 1