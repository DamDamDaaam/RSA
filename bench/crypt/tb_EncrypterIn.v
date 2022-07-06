`timescale 1ns / 100ps

module tb_EncrypterIn;
    
    reg clk = 1'b0;
    reg rst = 1'b1;
    reg start = 1'b0;
    
    reg [31:0] n_key = 32'b0;
    
    reg ready_in = 1'b0;
    reg [7:0] data_in = 8'b0;
    
    wire clear_rx_flag;
    wire start_out;
    wire n_len_out;
    wire fme_start;
    wire [31:0] fme_data_in;
    
    EncrypterIn DUT(
        //INPUT
        .clk           (clk),
        .rst           (rst),
        .start         (start),
        
        .n_key         (n_key),
        
        .ready_in      (ready_in),
        .data_in       (data_in),
        
        //OUTPUT
        .clear_rx_flag (clear_rx_flag),
       
        .start_out     (start_out),
        .n_len_out     (n_len_out),
        
        .fme_start     (fme_start),
        .fme_data_in   (fme_data_in)
    );
    
    initial begin
        forever #5 clk = ~clk;
    end
    
    always @(posedge clk) begin
        if (clear_rx_flag)
            ready_in = 1'b0;
    end
    
    initial begin
        #33    rst = 1'b0;                                 
        #100   n_key = 32'b00001101010000101001010101010101;
        #10    start = 1'b1;
        #10    start = 1'b0;
        
        #500   ready_in = 1'b1;
               data_in  = 8'b11101011;
        
        #16000 ready_in = 1'b1;
               data_in = 8'b11001011;
        
        #16000 ready_in = 1'b1;
               data_in = 8'b10000011;
        
        #16000 ready_in = 1'b1;
               data_in = 8'b11111111;
        
        #32000 ready_in = 1'b1;
               data_in  = 8'b11101011;
        
        #16000 ready_in = 1'b1;
               data_in = 8'b11001011;
        
        #16000 ready_in = 1'b1;
               data_in = 8'b10000011;
        
        #32000 ready_in = 1'b1;
               data_in = 8'b11111111;
        
        #16000 $finish;
    end
    
endmodule
