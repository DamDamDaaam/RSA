
`timescale 1ns / 100ps

module tb_FastModExp;
    
    reg clk = 1'b0;
    reg rst = 1'b1;
    reg start = 1'b0;
    
    reg [31:0] base = 32'b0;
    reg [31:0] exponent = 32'b0;
    reg [31:0] modulo = 32'b0;
    
    wire [31:0] result;
    wire done;
    
    FastModExp DUT (
    
        .clk        (clk     ),
        .rst        (rst     ),
        .start      (start   ),
        
        .base       (base    ),
        .exponent   (exponent),
        .modulo     (modulo  ),
        
        .result     (result  ),
        .done       (done    )
    
    );
    
    initial begin
        forever #5 clk = ~clk;
    end
    
    
    initial begin
        #55     rst = 1'b0;
        #100    base     = 32'b00000000111001100101010101010101;
                exponent = 32'd15432757;
                modulo   = 32'd16805071;
        #50     start = 1'b1;
        #10     start = 1'b0;
        #30000  $finish;
    end
    
endmodule

