`timescale 1ns / 100ps

//Modulo che gestisce le operazioni di cifratura e decifratura dei messaggi

//L'encoding utilizzato è latin1, in cui tutti i caratteri sono di dimensione 1 byte.
//Se si cerca di criptare messaggi in encoding originale UTF-8, gli eventuali caratteri di
//dimensione 2 byte risulteranno sbagliati dopo la decifratura

//Non devono essere criptati con questo dispositivo file che contengono i caratteri NUL e/o EOT

//Il cifrato prodotto risulta più lungo rispetto al messaggio originale, secondo la proporzione
//l_cifrato = l_messaggio * 32 / (n_len - 1)
//dove l_cifrato e l_messaggio sono in byte e n_len è la lunghezza in bit della chiave n

//Il messaggio in chiaro ottenuto tramite decifratura può terminare con fino a tre caratteri NUL
//aggiuntivi, non presenti nel messaggio originale ed eliminati via software

module Crypter (
    
    input wire clk,
    input wire rst,
    input wire mode,        // collegabile direttamente a SW[2] (mode[0])
    
    input wire start,
    
    input wire [31:0] n_key,
    input wire [31:0] e_key,
    input wire [31:0] d_key,

    input wire eot_in,
    input wire ready_in,
    input wire [7:0] data_in,
    
    input wire tx_done_tick,
    output reg start_out,
    output reg [7:0] data_out,
    output wire clear_rx_flag,
    
    output reg busy
    );
    
    /////////////////////////////////
    // DATA PACKING FOR ENCRYPTION //
    /////////////////////////////////
    
    reg  start_enc;
    reg  clear_rx_flag_enc;
    wire [7:0] n_len_out;
    wire fme_start_enc;
    wire [31:0] fme_data_in_enc;
    
    EncrypterIn encrypter_in (
        .clk           (clk),
        .rst           (rst),
        .start         (start_enc),
        
        .n_key         (n_key),
        
        .eot_in        (eot_in),
        .ready_in      (ready_in),  //Questo deve arrivare da UART (rx_flag)
        .data_in       (data_in),   //Dati letti dalla UART
        
        
        .clear_rx_flag (clear_rx_flag_enc),  //Questi devono andare alla UART
        .start_out     (send_n_len),
        .n_len_out     (n_len_out),
        
        .fme_start     (fme_start_enc),
        .fme_data_in   (fme_data_in_enc)
    );
    
    /////////////////////////////////////
    // DATA UNPACKING AFTER ENCRYPTION //
    /////////////////////////////////////
    
    reg word_ready_enc;
    wire [31:0] message_out;
    wire sending_word_enc;
    wire send_cipher;
    wire [7:0] cipher_byte;
    
    EncrypterOut encrypter_out (
        .clk           (clk),
        .rst           (rst),
        .tx_done_tick  (tx_done_tick), //Dalla UART
        .word_ready    (word_ready_enc),
        .data_in       (message_out),
        
        .sending_word  (sending_word_enc),
        .tx_start      (send_cipher),
        .data_out      (cipher_byte)
    );
    
    /////////////////////////////////
    // DATA PACKING FOR DECRYPTION //
    /////////////////////////////////
    
    reg  start_dec;
    reg  clear_rx_flag_dec;
    wire fme_start_dec;
    wire [31:0] fme_data_in_dec;
    wire last_word_tick;
    
    DecrypterIn decrypter_in (
        .clk            (clk),
        .rst            (rst),
        .start          (start_dec),
        
        .ready_in       (ready_in),
        .data_in        (data_in),
        
        .clear_rx_flag  (clear_rx_flag_dec),
        
        .fme_start      (fme_start_dec),
        .fme_data_in    (fme_data_in_dec),
        
        .last_word_tick (last_word_tick)
        
    );
    
    /////////////////////////////////////
    // DATA UNPACKING AFTER DECRYPTION //
    /////////////////////////////////////
    
    reg word_ready_dec;
    wire sending_word_dec;
    wire send_message;
    wire [7:0] message_byte;
    //TEST
    wire dec_done_tick;
    //TEST
    
    DecrypterOut decrypter_out (
        .clk            (clk),
        .rst            (rst),
        .start          (start_dec),
        
        .n_key          (n_key),
        
        .word_ready     (word_ready_dec),
        .data_in        (message_out),
        
        .last_word_tick (last_word_tick),
        
        .tx_done_tick   (tx_done_tick),
        
        .sending_word   (sending_word_dec),
        .tx_start       (send_message),
        .data_out       (message_byte),
        
        .done_tick      (dec_done_tick)
        
    );
    
    ////////////////////////////////////////
    // FAST MODULAR EXPONENTIATION MODULE //
    ////////////////////////////////////////
    
    reg fme_start;              //tick per avviare la conversione
    reg [31:0] fme_data_in;
    reg [31:0] key;
    
    wire fme_done;
        
    FastModExp fme_crypt (
        .clk        (clk),
        .rst        (rst),
        .start      (fme_start),
        
        .base       (fme_data_in),
        .exponent   (key),
        .modulo     (n_key),
        
        .result     (message_out),
        .done       (fme_done)
    );
    
    /////////////////////////////////////////////
    // MULTIPLEXERS FOR TX DATA AND FastModExp //
    /////////////////////////////////////////////
    
    assign start_out = send_n_len | send_cipher | send_message;
    assign clear_rx_flag = clear_rx_flag_enc | clear_rx_flag_dec;
    
    always @(*) begin
        if (send_n_len)
            data_out = n_len_out;
        else if (send_cipher)
            data_out = cipher_byte;
        else if (send_message)
            data_out = message_byte;
        else
            data_out = 8'b0;
        
        if (mode) begin //Se la modalità è cifratura
            fme_start = fme_start_enc;
            fme_data_in = fme_data_in_enc;
            key = e_key;
            start_enc = start;
            start_dec = 1'b0;
            word_ready_enc = fme_done;
            word_ready_dec = 1'b0;
        end
        else begin
            fme_start = fme_start_dec;
            fme_data_in = fme_data_in_dec;
            key = d_key;
            start_enc = 1'b0;
            start_dec = start;
            word_ready_enc = 1'b0;
            word_ready_dec = fme_done;
        end
    end
    
    //////////////////////////
    // BUSY SIGNAL HANDLING //
    //////////////////////////
    
    reg eot_received = 1'b0;
    reg sending_last_word = 1'b0;
    
    always @(posedge clk) begin
        if (rst) begin
            busy <= 1'b0;
            eot_received <= 1'b0;
            sending_last_word <= 1'b0;
        end
        else begin
            if (start)
                busy <= 1'b1;
            if (mode) begin    //Gestione del busy per la cifratura
                if (eot_in)
                    eot_received <= 1'b1;
                if (eot_received & word_ready_enc)
                    sending_last_word <= 1'b1;
                if (sending_last_word & ~sending_word_enc) begin
                    busy <= 1'b0;
                    eot_received <= 1'b0;
                    sending_last_word <= 1'b0;
                end
            end
            else begin         //Gestione del busy per la decifratura
                if (dec_done_tick)
                    busy <= 1'b0;
            end
        end
    end
    
endmodule
