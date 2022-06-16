`timescale 1ns / 100ps

module tb_UART_Transmitter;
    
    reg clk = 1'b0;
    reg rst = 1'b1;
    reg baud_tick = 1'b0;
    reg start = 1'b0;
    reg [7:0] data = 8'b0;
    
    wire tx;
    wire ready;
    
    reg [6:0] count = 0;
    
    UART_Transmitter DUT (
        .clk       (clk),
        .rst       (rst),
        .baud_tick (baud_tick),
        .start     (start),
        .data      (data),
        
        .tx        (tx),
        .ready     (ready)
    );
    
    initial begin
        forever #5 clk = ~clk;
    end
    
    always @(posedge clk) begin
        count <= count + 7'b1;
        if (count == 7'd9) begin
            count <= 7'b0;
            baud_tick <= 1'b1;
        end
        else
            baud_tick <= 1'b0;
    end
    
    initial begin
        #35 rst = 1'b0;
        
        #100 data = 8'b01010101;
        #100 start = 1'b1;
        #10  start = 1'b0;
        
        #20000 data = 8'b01011011;
        #50 start = 1'b1;
        #10  start = 1'b0;
        
        #20000 data = 8'b11100011;
        #80 start = 1'b1;
        #10  start = 1'b0;
        
        #20000 data = 8'b01011001;
        #130 start = 1'b1;
        #10  start = 1'b0;
        
        #50000 $finish;
    end
    
endmodule
