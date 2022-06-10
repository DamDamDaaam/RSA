
`timescale 1ns / 100ps

module TestBenchHW(
    
    input wire clk,
    input wire [1:0] mode_select,
    input wire out_en,
    input wire var_sel,

    input wire start,
    input wire rst,
    input wire increment,
    input wire button,
    
    output wire [7:0] display,
    output wire [11:0] anode
    
    );
    
    reg [31:0] bin_val;
    reg [24:0] flag;
    
    always @(posedge(clk)) begin
        if(rst)
            bin_val = 32'd0;
        else begin
            if(increment)
                bin_val = bin_val + 1;
            else
                if(button) begin
                    if(flag == 24'd0)
                        bin_val = bin_val + 1;

                    flag = flag + 24'd1;
                    
                end
        end
    end

    
    wire [39:0] BCD_val;
    
    ConverterBCD_Comb (
        .bin(bin_val),
        .bcd(BCD_val)
    );

    
    reg [3:0] show_mode;
    
    always @(*) begin
        case(mode_select[1:0])
            2'b00 :
                show_mode = 4'ha;
            2'b01 :
                if(var_sel==1'b0)
                    show_mode = 4'h5;
                else
                    show_mode = 4'hb;
            2'b11 :
                show_mode = 4'hc;
            2'b10 :
                if(start == 1'b1)
                    show_mode = 4'hf;
                else
                    if(var_sel==1'b0)
                        show_mode = 4'hd;
                    else
                        show_mode = 4'he;
        endcase
    end
    
    SevenSegment_12_Digits (
        
    .clk    (       clk ),
    .en     (    out_en ),
    .mode   ( show_mode ),    // input della mode da stampare a video
    .BCD    (   BCD_val ),     // input del numero da stampare a video
    
    .segA   ( display[7] ),
    .segB   ( display[6] ),
    .segC   ( display[5] ),
    .segD   ( display[4] ),
    .segE   ( display[3] ),
    .segF   ( display[2] ),
    .segG   ( display[1] ),
    .DP     ( display[0] ),
    .anode  (      anode )
    
    );
    
endmodule
