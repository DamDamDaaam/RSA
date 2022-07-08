`timescale 1ns / 100ps

module tb_EncrypterOut;

    reg clk = 1'b0;
    reg rst = 1'b1;
    
    reg rx_stream = 1'b1;
    wire tx_stream;
    
    reg rx_used_tick = 1'b0;
    wire rx_readable;
    wire [7:0] rx_data;
    
    reg tx_start = 1'b0;
    wire [7:0] tx_data;
    wire tx_busy;
    wire tx_done_tick;

    UART uart (
        .clk       (clk),
        .rst       (rst),
        
        .rx_stream (rx_stream),
        .tx_stream (tx_stream),
    
        .rx_used_tick (rx_used_tick),
        .rx_readable  (rx_readable),
        .rx_data      (rx_data),
    
        .tx_start     (tx_start),
        .tx_data      (tx_data),
        .tx_busy      (tx_busy),
        .tx_done_tick (tx_done_tick)
    );
    
    reg word_ready = 1'b0;
    reg [31:0] data_in = 32'b0;
    wire sending_word;
    
    EncrypterOut DUT (
        .clk           (clk),
        .rst           (rst),
        .tx_done_tick  (tx_done_tick),
        .word_ready    (word_ready),
        .data_in       (data_in),
        
        .sending_word  (sending_word),
        .tx_start      (tx_start),
        .data_out      (tx_data)
    );
    
    initial begin
        forever #5 clk = ~clk;
    end
    
    //Transmitter test
    initial begin
        #35 rst = 1'b0;
        
        #100 data_in = 32'b01010101001100110000111101011001;
        #100 word_ready = 1'b1;
        #10  word_ready = 1'b0;
        
        //#70000 $finish;
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
        #400  rx_used_tick = 1'b1;
        #10   rx_used_tick = 1'b0;
        
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
        #400  rx_used_tick = 1'b1;
        #10   rx_used_tick = 1'b0;
        
        //EOT character
        #1600 rx_stream = 1'b0; //START
        #1600 rx_stream = 1'b0;
        #1600 rx_stream = 1'b0;
        #1600 rx_stream = 1'b1;
        #1600 rx_stream = 1'b0;
        #1600 rx_stream = 1'b0;
        #1600 rx_stream = 1'b0;
        #1600 rx_stream = 1'b0;
        #1600 rx_stream = 1'b0;
        #1600 rx_stream = 1'b1; //STOP
        #400  rx_used_tick = 1'b1;
        #10   rx_used_tick = 1'b0;
        
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
        #400  rx_used_tick = 1'b1;
        #10   rx_used_tick = 1'b0;
        
        //EOT character
        #1600 rx_stream = 1'b0; //START
        #1600 rx_stream = 1'b0;
        #1600 rx_stream = 1'b0;
        #1600 rx_stream = 1'b1;
        #1600 rx_stream = 1'b0;
        #1600 rx_stream = 1'b0;
        #1600 rx_stream = 1'b0;
        #1600 rx_stream = 1'b0;
        #1600 rx_stream = 1'b0;
        #1600 rx_stream = 1'b1; //STOP
        #400  rx_used_tick = 1'b1;
        #10   rx_used_tick = 1'b0;
        
        #16000 $finish;
    end
    
endmodule
