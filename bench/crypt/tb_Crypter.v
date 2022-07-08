`timescale 1ns / 100ps

module tb_Crypter;

    reg clk = 1'b0;
    reg rst = 1'b1;
    reg start = 1'b0;
    reg mode = 1'b0;
    
    reg [31:0] n_key = 32'b0;
    reg [31:0] e_key = 32'b0;
    reg [31:0] d_key = 32'b0;
    
    reg eot_in = 1'b0;
    reg ready_in = 1'b0;
    reg [7:0] data_in = 8'b0;
    reg tx_done_tick = 1'b0;
    
    wire start_out;
    wire [7:0] data_out;
    wire clear_rx_flag;
    
    Crypter DUT (
        .clk       (clk),
        .rst       (rst),
        .mode      (mode),        // collegabile direttamente a SW[2] (mode[0])
       
        .start     (start),       // da collegare a start di KeyManager E non busy
        
        .n_key     (n_key),
        .e_key     (e_key),
        .d_key     (d_key),

        .eot_in    (eot_in),
        .ready_in  (ready_in),
        .data_in   (data_in),
        .tx_done_tick (tx_done_tick),
        
        //OUTPUT
        .start_out     (start_out),
        .data_out      (data_out),
        .clear_rx_flag (clear_rx_flag)
    );
    
    initial begin
        forever #5 clk = ~clk;
    end
    
    always @(posedge clk) begin
        if (clear_rx_flag) begin
            ready_in = 1'b0;
            eot_in   = 1'b0;
        end
    end
    
    always @(posedge clk) begin
        if (start_out) begin
             #16000 tx_done_tick = 1'b1;
             #10    tx_done_tick = 1'b0;
        end
    end
    
    /*initial begin                     //Testbench per encrypter
        #33    rst = 1'b0;
               mode = 1'b1;
               
        #100   n_key = 32'd96022049;
               e_key = 32'd88637233;
               d_key = 32'd39370597;
               
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
        
        #64000 ready_in = 1'b1;
               data_in  = 8'b00000100;
               eot_in   = 1'b1;
        
        #16000 ready_in = 1'b1;
               data_in = 8'b11001011;
        
        #64000 ready_in = 1'b1;
               data_in = 8'b10000011;
        
        #32000 ready_in = 1'b1;
               data_in = 8'b11111111;
        
        #16000 $finish;
    end*/
    
    initial begin
        #33    rst = 1'b0;  
                                       
        #100   n_key = 32'd96022049;
               e_key = 32'd88637233;
               d_key = 32'd39370597;
               
        #10    start = 1'b1;
        #10    start = 1'b0;
        
        //LUNGHEZZA CIFRATO
        #500   ready_in = 1'b1;
               data_in  = 8'b00000000;
        
        #500 ready_in = 1'b1;
               data_in = 8'b00000000;
        
        #500 ready_in = 1'b1;
               data_in = 8'b00000000;
        
        #500 ready_in = 1'b1;
               data_in = 8'b00000100;
        
        //PRIMA WORD
        #1000 ready_in = 1'b1;
               data_in  = 8'b00000100;
        
        #500 ready_in = 1'b1;
               data_in = 8'b11001011;
        
        #500 ready_in = 1'b1;
               data_in = 8'b10000011;
        
        #500 ready_in = 1'b1;
               data_in = 8'b11111111;
        
        #500 ready_in = 1'b1;
               data_in = 8'b11111111;
        
        //SECONDA
        #1000 ready_in = 1'b1;
               data_in  = 8'b00000100;
        
        #500 ready_in = 1'b1;
               data_in = 8'b11001011;
        
        #500 ready_in = 1'b1;
               data_in = 8'b10000011;
        
        #500 ready_in = 1'b1;
               data_in = 8'b11111111;
        
        //TERZA
        #1000 ready_in = 1'b1;
               data_in  = 8'b00000100;
        
        #500 ready_in = 1'b1;
               data_in = 8'b11001011;
        
        #500 ready_in = 1'b1;
               data_in = 8'b10000011;
        
        #500 ready_in = 1'b1;
               data_in = 8'b11111111;
        
        //QUARTA
        #1000 ready_in = 1'b1;
               data_in  = 8'b00000100;
        
        #500 ready_in = 1'b1;
               data_in = 8'b11001011;
        
        #500 ready_in = 1'b1;
               data_in = 8'b10000011;
        
        #500 ready_in = 1'b1;
               data_in = 8'b11111111;
        
        //QUINTA
        #1000 ready_in = 1'b1;
               data_in  = 8'b00000100;
        
        #500 ready_in = 1'b1;
               data_in = 8'b11001011;
        
        #500 ready_in = 1'b1;
               data_in = 8'b10000011;
        
        #500 ready_in = 1'b1;
               data_in = 8'b11111111;
        #1000 $finish;
    end    
    
endmodule
