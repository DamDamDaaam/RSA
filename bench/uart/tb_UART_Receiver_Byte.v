`timescale 1ns / 100ps

module tb_UART_Receiver_Byte;
    
    reg clk = 1'b0;
    reg rst = 1'b1;
    reg baud_tick = 1'b0;
    reg rx = 1'b1;
    wire data_valid;
    wire [7:0] data_out;
    
    reg [6:0] count = 0;
    
    UART_Receiver_Byte DUT (
        .clk        (clk),
        .rst        (rst),
        .baud_tick  (baud_tick),
        .rx         (rx),
        
        .data_valid (data_valid), 
        .data       (data_out) 
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
        
        #373  rx = 1'b0; //START
        #1600 rx = 1'b0;
        #1600 rx = 1'b1;
        #1600 rx = 1'b0;
        #1600 rx = 1'b1;
        #1600 rx = 1'b1;
        #1600 rx = 1'b0;
        #1600 rx = 1'b0;
        #1600 rx = 1'b1;
        #1600 rx = 1'b1; //STOP
        
        #1600 rx = 1'b0; //START
        #1600 rx = 1'b0;
        #1600 rx = 1'b1;
        #1600 rx = 1'b0;
        #1600 rx = 1'b1;
        #1600 rx = 1'b1;
        #1600 rx = 1'b0;
        #1600 rx = 1'b0;
        #1600 rx = 1'b1;
        #1600 rx = 1'b1; //STOP
        
        #1600 rx = 1'b0; //START
        #1600 rx = 1'b0;
        #1600 rx = 1'b1;
        #1600 rx = 1'b0;
        #1600 rx = 1'b1;
        #1600 rx = 1'b1;
        #1600 rx = 1'b0;
        #1600 rx = 1'b0;
        #1600 rx = 1'b1;
        #1600 rx = 1'b1; //STOP
        
        #4654 rx = 1'b0; //START
        #1600 rx = 1'b0;
        #1600 rx = 1'b1;
        #1600 rx = 1'b0;
        #1600 rx = 1'b1;
        #1600 rx = 1'b1;
        #1600 rx = 1'b0;
        #1600 rx = 1'b0;
        #1600 rx = 1'b1;
        #1600 rx = 1'b1; //STOP
        
        #404 rx = 1'b0; //START
        #1600 rx = 1'b1;
        #1600 rx = 1'b1;
        #1600 rx = 1'b0;
        #1600 rx = 1'b1;
        #1600 rx = 1'b1;
        #1600 rx = 1'b0;
        #1600 rx = 1'b0;
        #1600 rx = 1'b1;
        #1600 rx = 1'b1; //STOP
        
        #1600 rx = 1'b0; //START
        #1600 rx = 1'b1;
        #1600 rx = 1'b1;
        #1600 rx = 1'b0;
        #1600 rx = 1'b1;
        #1600 rx = 1'b1;
        #1600 rx = 1'b0;
        #1600 rx = 1'b0;
        #1600 rx = 1'b1;
        #1600 rx = 1'b1; //STOP
        
        #1600 rx = 1'b0; //START
        #1600 rx = 1'b1;
        #1600 rx = 1'b1;
        #1600 rx = 1'b0;
        #1600 rx = 1'b1;
        #1600 rx = 1'b1;
        #1600 rx = 1'b0;
        #1600 rx = 1'b0;
        #1600 rx = 1'b1;
        #1600 rx = 1'b1; //STOP
        
        #1600 rx = 1'b0; //START
        #1600 rx = 1'b0;
        #1600 rx = 1'b1;
        #1600 rx = 1'b0;
        #1600 rx = 1'b1;
        #1600 rx = 1'b1;
        #1600 rx = 1'b0;
        #1600 rx = 1'b0;
        #1600 rx = 1'b0;
        #1600 rx = 1'b1; //STOP
        
        #1600 rx = 1'b0; //START
        #1600 rx = 1'b0;
        #1600 rx = 1'b1;
        #1600 rx = 1'b0;
        #1600 rx = 1'b1;
        #1600 rx = 1'b1;
        #1600 rx = 1'b0;
        #1600 rx = 1'b0;
        #1600 rx = 1'b0;
        #1600 rx = 1'b1; //STOP
        
        #1600 rx = 1'b0; //START
        #1600 rx = 1'b0;
        #1600 rx = 1'b1;
        #1600 rx = 1'b0;
        #1600 rx = 1'b1;
        #1600 rx = 1'b1;
        #1600 rx = 1'b0;
        #1600 rx = 1'b0;
        #1600 rx = 1'b0;
        #1600 rx = 1'b1; //STOP
        
        #100 $finish;
    end
    
endmodule