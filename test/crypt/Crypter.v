`timescale 1ns / 100ps

//TODO correggere commenti outdated

//Il modulo cripta e decripta stream di bit prodotti leggendo i byte dal primo all'ultimo e leggendo ogni byte da LSB a MSB. Questo causa uno scrambling dei valori durante l'impacchettamento, ma al momento di decriptare questo scrambling viene annullato.

//I valori che vengono criptati sono blocchi da 32 bit ottenuti aggiungendo zeri di padding a sinistra fino ad arrivare a 32 dopo aver impacchettato un numero di bit di input pari al numero di bit della chiave N meno 1

//I valori che vengono decriptati 

module Crypter (
    
    input wire clk,
    input wire rst,
  //input wire en,          // collegabile direttamente a SW[3] (mode[1])
    input wire mode,        // collegabile direttamente a SW[2] (mode[0])
    
    input wire start,       // da collegare a start di KeyManager E non busy
    
    input wire [31:0] n_key,
    input wire [31:0] e_key,
    input wire [31:0] d_key,

    input wire eot_in,
    input wire ready_in,
    input wire [7:0] data_in,
    
    input wire tx_done_tick,
    output reg start_out,
    output reg [7:0] data_out,
    output wire clear_rx_flag
    
    );
    
    /////////////////////////////////
    // DATA PACKING FOR ENCRYPTION //
    /////////////////////////////////
    
    reg  start_enc;
    reg  clear_rx_flag_enc;
    wire fme_start_enc;
    wire [31:0] fme_data_in_enc;
    
    EncrypterIn encrypter_in (
        .clk           (clk),
        .rst           (rst),
        .start         (start_enc),
        
        .n_key         (n_key),
        
        .eot_in        (eot_in),
        .ready_in      (ready_in),  //Questo deve arrivare da UART_Pong (rx_flag)
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
    
    wire sending_word;
    wire send_cipher;
    wire [7:0] cipher_byte;
    
    EncrypterOut encrypter_out (
        .clk           (clk),
        .rst           (rst),
        .tx_done_tick  (tx_done_tick), //Dalla UART
        .word_ready    (fme_done),
        .data_in       (message_out),
        
        .sending_word  (sending_word), //Eventualmente usare per debug in hardware
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
    
    DecrypterIn decrypter_in (
        .clk           (clk),
        .rst           (rst),
        .start         (start_dec),
        
        .ready_in      (ready_in),
        .data_in       (data_in),
        
        .clear_rx_flag (clear_rx_flag_dec),
        
        .fme_start     (fme_start_dec),
        .fme_data_in   (fme_data_in_dec)
    );
    
    ////////////////////////////////////////
    // FAST MODULAR EXPONENTIATION MODULE //
    ////////////////////////////////////////
    
    reg fme_start;              //tick per avviare la conversione
    reg [31:0] fme_data_in;
    reg [31:0] key;
    
    wire [31:0] message_out;
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
    
    wire [7:0] n_len_out;
    
    assign start_out = send_n_len | send_cipher; //Aggiungere in OR gli altri segnali di tx_start
    assign clear_rx_flag = clear_rx_flag_enc | clear_rx_flag_dec;
    
    always @(*) begin
        if (send_n_len)
            data_out = n_len_out;
        else if (send_cipher)
            data_out = cipher_byte;
        else
            data_out = 8'b0;
        
        if (mode) begin //Se la modalità è crittaggio
            fme_start = fme_start_enc;
            fme_data_in = fme_data_in_enc;
            key = e_key;
            start_enc = start;
            start_dec = 1'b0;
        end
        else begin
            fme_start = fme_start_dec;
            fme_data_in = fme_data_in_dec;
            key = d_key;
            start_enc = 1'b0;
            start_dec = start;
        end
    end
    
endmodule
