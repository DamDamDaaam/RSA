`timescale 1ns / 100ps

module tb_ROM;

    reg clk = 1'b0;
    //reg en = 1'b0;
    reg [12:0] addr = 13'b0;
    wire [15:0] data;

    TestROM_Manual DUT (
        .clk  (clk),
        .addr (addr),
        .data (data)
    );

    initial begin
        forever #5 clk = ~clk;
    end

    always @(negedge clk) begin
        //if (en) begin
            addr = addr + 13'b1;
        //end
    end
    
    initial begin
        //#100 en = 1'b1;
        #1000 $finish;
    end

endmodule
