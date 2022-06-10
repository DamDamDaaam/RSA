`timescale 1ns / 100ps

module tb_Multiplier_16bit;
    
    reg clk = 1'b0;
    reg [15:0] a = 16'b0;
    reg [15:0] b = 16'b0;
    
    wire [31:0] product;
    
    Multiplier_16bit DUT (
        .CLK (clk),
        .A   (a),
        .B   (b),
        .P   (product)
    );
    
    initial begin
        forever #5 clk = ~clk;
    end
    
    reg en = 1'b0;
    
    initial begin
        forever #100 en = ~en;
    end
    
    always @(posedge clk) begin
        a <= a + 16'b1;
        if (en)
            b <= b + 16'b1;
    end
    
    initial begin
        #5000 $finish;
    end
    
endmodule
