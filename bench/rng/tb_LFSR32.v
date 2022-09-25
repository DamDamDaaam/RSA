`timescale 1ns / 100ps

module tb_LFSR32;

    reg clk         = 1'b0;
    reg en          = 1'b0;
    reg rst         = 1'b1;
    reg [31:0] rng  = 32'b0;    
    
    LFSR32 DUT (
        .clk          (clk),
        .rst          (rst),
        .en           (en),
        
        .rng_out      (rng)
    );
    
    initial begin
        forever #5 clk = ~clk;
    end
    
    //integer f;
    integer count = 0;
    
    always @(rng) begin
        if (en) begin
            //$fdisplay(f, "%d", rng);
            count = count + 1;
        end
        if (((rng == 32'b11010100101001010110101010101101) && (count > 10)) || (count == 4294967295)) begin
            //$fclose(f);
            $finish;
        end
    end
    
    initial begin
        //f = $fopen("/home/michele/rsa/bin/rng.txt");
        #105  rst = 1'b0;
        #100  en = 1'b1;
    end
    
endmodule
