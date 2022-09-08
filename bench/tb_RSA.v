`timescale 1ns / 100ps

module tb_RSA;
    
    reg clk = 1'b0;
    reg [1:0] mode = 2'b11;
    reg sel = 1'b0;
    
    reg del = 1'b0;
    reg start = 1'b0;
    reg select = 1'b0;
    reg add = 1'b0;
    
    reg rx = 1'b1;
    wire tx;
    
    wire [7:0] display;
    wire [11:0] anode;
    
    reg NC1 = 1'b0;
    reg NC2 = 1'b0;
    reg NC3 = 1'b0;
    reg NC4 = 1'b0;
    
    reg [7:0] bytes [0:3];
    reg [7:0] eot = 8'd4;
    
    RSA DUT (
        .clk_100      (clk),
        .mode_select  (mode),       // SW[3:2]
        .var_sel      (sel),                 // SW[0]
        
        .del_but      (NC1),                 // BTN[3]
        .start_but    (NC2),               // BTN[2]
        .select_but   (NC3),              // BTN[1]
        .add_but      (NC4),                 // BTN[0]
        
        .rx_stream    (rx),               // uart_txd_in
        .tx_stream    (tx),              // uart_rxd_out
        
        .display      (display),
        .anode        (anode)
    );
    
    initial begin
        forever #5 clk = ~clk;
    end
    
    initial begin
        force DUT.start = start;

        #1005; //Attesa di pll_locked
        
        DUT.chiavi.n_key = 32'd1450380913;
        DUT.chiavi.e_key = 32'd0095510521;
        DUT.chiavi.d_key = 32'd0422734761;
        
        #10   start = 1'b1;
        #10   start = 1'b0;
        
        bytes[0] = 8'b01101000; //h
        bytes[1] = 8'b01100101; //e
        bytes[2] = 8'b01101100; //l
        bytes[3] = 8'b01110000; //p
        
        for (integer i = 0; i < 4; i = i + 1) begin
            #52083 rx = 1'b0;
            for (integer k = 0; k < 8; k = k + 1) begin
               #52083 rx = bytes[i][k];
            end
            #52083 rx = 1'b1;
        end
        
        #25000; //delay FME
        #2083320; //delay UART
        
        rx = 1'b0;
        for (integer k = 0; k < 8; k = k + 1) begin
            #52083 rx = eot[k];
        end
        #52083 rx = 1'b1;
        
        #25000;
        #2083320 $finish;
    end
    
endmodule
