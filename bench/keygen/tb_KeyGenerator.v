`timescale 1ns / 100ps

module tb_KeyGenerator;
    
    reg clk = 1'b0;
    reg rst = 1'b1;
    reg en = 1'b0;
    reg start = 1'b0;
    
    wire [31:0] n_key;
    wire [31:0] e_key;
    wire [31:0] d_key;
    wire n_key_valid;
    wire e_key_valid;
    wire d_key_valid;
    wire busy;
    
    KeyGenerator DUT (
        .clk         (clk),
        .rst         (rst),
        .en          (en),
        .start       (start),
        
        .n_key       (n_key),
        .e_key       (e_key),
        .d_key       (d_key),
        
        .n_key_valid (n_key_valid),
        .e_key_valid (e_key_valid),
        .d_key_valid (d_key_valid),
        .busy        (busy)
    );
    
    initial begin
        forever #5 clk = ~clk;
    end
    
    initial begin
        #25    rst   = 1'b0;
        #50    en    = 1'b1;
        #50    start = 1'b1;
        #10    start = 1'b0;
        #6865   start = 1'b1;
        #10    start = 1'b0;
        #10000 $finish;
    end
    
endmodule
