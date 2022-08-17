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
/*
    initial begin                     //Testbench per encrypter
        #33    rst = 1'b0;
               mode = 1'b1;
               
        #100   n_key = 32'd96022049;
               e_key = 32'd88637233;
               d_key = 32'd39370597;
               
        #10    start = 1'b1;
        #10    start = 1'b0;
        
        #500   ready_in = 1'b1;
               data_in  = 8'b01101000;  //h     8
        
        #500 ready_in = 1'b1;
               data_in  = 8'b01100101;  //e     16
        
        #500 ready_in = 1'b1;
               data_in  = 8'b01101100;  //l     24
        
        #500 ready_in = 1'b1;
               data_in  = 8'b01101100;  //l     32 -> 6
        
        #32000 ready_in = 1'b1;
               data_in  = 8'b01101111;  //o     14
        
        #500   ready_in = 1'b1;
               data_in  = 8'b00100000;  //      22
        
        #500 ready_in = 1'b1;
               data_in  = 8'b01110111;  //w     30 -> 4
        
        #32000 ready_in = 1'b1;
               data_in  = 8'b01101111;  //o     12
        
        #500 ready_in = 1'b1;
               data_in  = 8'b01110010;  //r     20

        #500 ready_in = 1'b1;
               data_in  = 8'b01101100;  //l     28 -> 2
        
        #32000 ready_in = 1'b1;
               data_in  = 8'b01100100;  //d     10
        
        #500 ready_in = 1'b1;
               data_in  = 8'b00100001;  //!     18
        
        #500   ready_in = 1'b1;
               data_in  = 8'b00100000;  //      26 -> 0
        
        #32000   ready_in = 1'b1;
               data_in  = 8'b01101000;  //h     8
        
        #500 ready_in = 1'b1;
               data_in  = 8'b01100101;  //e     16
        
        #500 ready_in = 1'b1;
               data_in  = 8'b01101100;  //l     24
        
        #500 ready_in = 1'b1;
               data_in  = 8'b01101100;  //l     32 -> 6
        
        #32000 ready_in = 1'b1;
               data_in  = 8'b01101111;  //o     14
        
        #500   ready_in = 1'b1;
               data_in  = 8'b00100000;  //      22
        
        #500 ready_in = 1'b1;
               data_in  = 8'b01110111;  //w     30 -> 4
        
        #32000 ready_in = 1'b1;
               data_in  = 8'b01101111;  //o     12
        
        #500 ready_in = 1'b1;
               data_in  = 8'b01110010;  //r     20

        #500 ready_in = 1'b1;
               data_in  = 8'b01101100;  //l     28 -> 2
        
        #32000 ready_in = 1'b1;
               data_in  = 8'b01100100;  //d     10
        
        #500 ready_in = 1'b1;
               data_in  = 8'b00100001;  //!     18
        
        #500 ready_in = 1'b1;
               data_in  = 8'b00000100;  //EOT
               eot_in   = 1'b1;
        
        #32000 $finish;
    end
*/
    initial begin                   //Testbench per decrypter
        #33    rst = 1'b0;  //Modificato delay per garantire eventi sincroni
        
        #100   n_key = 32'd96022049;
               e_key = 32'd88637233;
               d_key = 32'd39370597;
        
        #10    start = 1'b1;
        #10    start = 1'b0;
        
        //LUNGHEZZA CIFRATO
        #500   ready_in = 1'b1;
               data_in  = 8'b00000000;
        
        #500   ready_in = 1'b1;
               data_in  = 8'b00000000;
        
        #500   ready_in = 1'b1;
               data_in  = 8'b00000000;
        
        #500   ready_in = 1'b1;
             //data_in  = 8'b00001000; //Uso due word per simulare più in fretta
               data_in  = 8'b00000010;
        
        //PRIMA WORD
        #1000 ready_in = 1'b1;
               data_in  = 8'b00000000;
        
        #16000 ready_in = 1'b1;
               data_in = 8'b11100101;
        
        #16000 ready_in = 1'b1;
               data_in = 8'b11111001;
        
        #16000 ready_in = 1'b1;
               data_in = 8'b11111011;
        
        //SECONDA
        #16000 ready_in = 1'b1;
               data_in  = 8'b00000001;
        
        #16000 ready_in = 1'b1;
               data_in = 8'b11100011;
        
        #16000 ready_in = 1'b1;
               data_in = 8'b00111010;
        
        #16000 ready_in = 1'b1;
               data_in = 8'b11010011;
        
        /*//TERZA
        #16000 ready_in = 1'b1;
               data_in  = 8'b00000100;
        
        #16000 ready_in = 1'b1;
               data_in = 8'b01000010;
        
        #16000 ready_in = 1'b1;
               data_in = 8'b01110101;
        
        #16000 ready_in = 1'b1;
               data_in = 8'b01001010;
        
        //QUARTA
        #16000 ready_in = 1'b1;
               data_in  = 8'b00000001;
        
        #16000 ready_in = 1'b1;
               data_in = 8'b01010110;
        
        #16000 ready_in = 1'b1;
               data_in = 8'b01101000;
        
        #16000 ready_in = 1'b1;
               data_in = 8'b00100110;
        
        //QUINTA
        #16000 ready_in = 1'b1;
               data_in  = 8'b00000000;
        
        #16000 ready_in = 1'b1;
               data_in = 8'b11100101;
        
        #16000 ready_in = 1'b1;
               data_in = 8'b11111001;
        
        #16000 ready_in = 1'b1;
               data_in = 8'b11111011;
        
        //SESTA
        #16000 ready_in = 1'b1;
               data_in  = 8'b00000001;
        
        #16000 ready_in = 1'b1;
               data_in = 8'b11100011;
        
        #16000 ready_in = 1'b1;
               data_in = 8'b00111010;
        
        #16000 ready_in = 1'b1;
               data_in = 8'b11010011;
        
        //SETTIMA
        #16000 ready_in = 1'b1;
               data_in  = 8'b00000100;
        
        #16000 ready_in = 1'b1;
               data_in = 8'b01000010;
        
        #16000 ready_in = 1'b1;
               data_in = 8'b01110101;
        
        #16000 ready_in = 1'b1;
               data_in = 8'b01001010;
        
        //OTTAVA
        #16000 ready_in = 1'b1;
               data_in  = 8'b00000100;
        
        #16000 ready_in = 1'b1;
               data_in = 8'b11010011;
        
        #16000 ready_in = 1'b1;
               data_in = 8'b01011001;
        
        #16000 ready_in = 1'b1;
               data_in = 8'b11010101;*/
        
        #80000 $finish;
    end

endmodule
