`timescale 1ns / 100ps

module tb_ConverterBCD_Comb;
    
    reg [31:0] bin_count = 31'b0;
    wire [39:0] bcd;
    wire [3:0] bcd_digits [9:0];
    
    genvar i;
    generate
        for (i = 0; i < 10; i = i + 1) begin
            assign bcd_digits[i] = bcd[4*i + 3 : 4*i];
        end
    endgenerate
    
    ConverterBCD_Comb DUT (
        .bin(bin_count),
        .bcd(bcd)
    );
    
    initial begin
        forever #5 bin_count = bin_count + 31'b1;
    end
    
    initial begin
        #860000 $finish;
    end

endmodule
