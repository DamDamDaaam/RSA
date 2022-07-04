`timescale 1ns / 100ps

module tb_UART_Receiver_Bit;
    
    reg clk = 1'b0;
    reg rst = 1'b1;
    reg baud_tick = 1'b0;
    reg rx = 1'b1;
    wire bit_ready;
    wire data_out;
    wire eot;
    
    reg [6:0] count = 0;
    
    UART_Receiver_Bit DUT (
        .clk       (clk),
        .rst       (rst),
        .baud_tick (baud_tick),
        .rx        (rx),
        
        .bit_ready (bit_ready), 
        .data_out  (data_out), 
        .eot       (eot)
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
        
        //Carattere EOT
        #1600 rx = 1'b0; //START
        #1600 rx = 1'b0;
        #1600 rx = 1'b0;
        #1600 rx = 1'b1;
        #1600 rx = 1'b0;
        #1600 rx = 1'b0;
        #1600 rx = 1'b0;
        #1600 rx = 1'b0;
        #1600 rx = 1'b0;
        #1600 rx = 1'b1; //STOP
        
        #3000 $finish;
    end
    
endmodule
