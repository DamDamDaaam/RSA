`timescale 1ns / 100ps

module tb_UART;

    reg clk = 1'b0;
    reg rst = 1'b1;
    
    reg rx_stream = 1'b1;
    wire tx_stream;
    
    wire rx_bit;
    wire rx_ready;
    
    reg tx_start = 1'b0;
    reg [7:0] tx_data = 8'b0;
    wire tx_ready;

    UART DUT (
        .clk       (clk),
        .rst       (rst),
        
        .rx_stream (rx_stream),
        .tx_stream (tx_stream),
    
        .rx_bit    (rx_bit),
        .rx_ready  (rx_ready), 
    
        .tx_start  (tx_start),
        .tx_data   (tx_data),
        .tx_ready  (tx_ready)
    );
    
    initial begin
        forever #5 clk = ~clk;
    end
    
    //Transmitter test
    initial begin
        #35 rst = 1'b0;
        
        #100 tx_data = 8'b01010101;
        #100 tx_start = 1'b1;
        #10  tx_start = 1'b0;
        
        #20000 tx_data = 8'b01011011;
        #50    tx_start = 1'b1;
        #10    tx_start = 1'b0;
        
        #20000 tx_data = 8'b11100011;
        #80    tx_start = 1'b1;
        #10    tx_start = 1'b0;
        
        #20000 tx_data = 8'b01011001;
        #130   tx_start = 1'b1;
        #10    tx_start = 1'b0;
        
        #50000 $finish;
    end
    
    //Receiver test
    initial begin
        #373  rx_stream = 1'b0; //START
        #1600 rx_stream = 1'b0;
        #1600 rx_stream = 1'b1;
        #1600 rx_stream = 1'b0;
        #1600 rx_stream = 1'b1;
        #1600 rx_stream = 1'b1;
        #1600 rx_stream = 1'b0;
        #1600 rx_stream = 1'b0;
        #1600 rx_stream = 1'b1;
        #1600 rx_stream = 1'b1; //STOP
        
        #1600 rx_stream = 1'b0; //START
        #1600 rx_stream = 1'b0;
        #1600 rx_stream = 1'b1;
        #1600 rx_stream = 1'b0;
        #1600 rx_stream = 1'b1;
        #1600 rx_stream = 1'b1;
        #1600 rx_stream = 1'b0;
        #1600 rx_stream = 1'b0;
        #1600 rx_stream = 1'b1;
        #1600 rx_stream = 1'b1; //STOP
        
        #1600 rx_stream = 1'b0; //START
        #1600 rx_stream = 1'b0;
        #1600 rx_stream = 1'b1;
        #1600 rx_stream = 1'b0;
        #1600 rx_stream = 1'b1;
        #1600 rx_stream = 1'b1;
        #1600 rx_stream = 1'b0;
        #1600 rx_stream = 1'b0;
        #1600 rx_stream = 1'b1;
        #1600 rx_stream = 1'b1; //STOP
        
        #2404 rx_stream = 1'b0; //START
        #1600 rx_stream = 1'b1;
        #1600 rx_stream = 1'b1;
        #1600 rx_stream = 1'b0;
        #1600 rx_stream = 1'b1;
        #1600 rx_stream = 1'b1;
        #1600 rx_stream = 1'b0;
        #1600 rx_stream = 1'b0;
        #1600 rx_stream = 1'b1;
        #1600 rx_stream = 1'b1; //STOP
        
        #1600 rx_stream = 1'b0; //START
        #1600 rx_stream = 1'b1;
        #1600 rx_stream = 1'b1;
        #1600 rx_stream = 1'b0;
        #1600 rx_stream = 1'b1;
        #1600 rx_stream = 1'b1;
        #1600 rx_stream = 1'b0;
        #1600 rx_stream = 1'b0;
        #1600 rx_stream = 1'b1;
        #1600 rx_stream = 1'b1; //STOP
    end
    
endmodule
