`timescale 1ns / 100ps

//TODO Aggiungere "end of transmission" al receiver UART (che guarda un byte alla volta i dati in ingresso e controlla una sequenza dedicata)
//TODO Creare la macchina a stati che trasmette i dati criptati alla UART

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

    input wire data_in,
    input wire ready_in,
    
    input wire ready_out,
    output reg start_out,
    output reg [7:0] data_out
    
    );
    
    ////////////////////////////////////////
    // FAST MODULAR EXPONENTIATION MODULE //
    ////////////////////////////////////////
    
    wire fme_start;              //tick per avviare la conversione
    wire [31:0] fme_data_in;
    wire [31:0] key;
    
    wire [31:0] message_out;
    wire fme_done;
    
    assign key = (mode) ? e_key : d_key;
    
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
    
    /////////////////////////////////
    // DATA PACKING FOR ENCRYPTION //
    /////////////////////////////////
    
    EncrypterIn encrypter_in (
        .clk           (clk),
        .rst           (rst),
        .start         (start),
        
        .n_key         (n_key),
        
        .ready_in      (ready_in),  //Questo deve arrivare da UART_Pong (rx_flag)
        .data_in       (data_in),   //Dati letti dalla UART
        
        
        .clear_rx_flag (clear_rx_flag),  //Questi devono andare alla UART
        .start_out     (start_out),
        .n_len_out     (n_len_out),
        
        .fme_start     (fme_start),
        .fme_data_in   (fme_data_in)
    );
    
endmodule
