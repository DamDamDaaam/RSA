`timescale 1ns / 100ps

//TODO Aggiungere "end of transmission" al receiver UART (che guarda un byte alla volta i dati in ingresso e controlla una sequenza dedicata)
//TODO Creare la macchina a stati che trasmette i dati criptati alla UART

//Il modulo cripta e decripta stream di bit prodotti leggendo i byte dal primo all'ultimo e leggendo ogni byte da LSB a MSB. Questo causa uno scrambling dei valori durante l'impacchettamento, ma al momento di decriptare questo scrambling viene annullato.

//I valori che vengono criptati sono blocchi da 32 bit ottenuti aggiungendo zeri di padding a sinistra fino ad arrivare a 32 dopo aver impacchettato un numero di bit di input pari al numero di bit della chiave N meno 1

//I valori che vengono decriptati 

module Crypter (
    
    input wire clk,
    input wire rst,
    input wire en,          // collegabile direttamente a SW[3] (mode[1])
    input wire mode,        // collegabile direttamente a SW[2] (mode[0])
    
    input wire start,       // da collegare a start di KeyManager E non busy
    
    input wire [31:0] n_key,
    input wire [31:0] e_key,
    input wire [31:0] d_key,

    input wire data_in,
    input wire read_in,
    
    input wire ready_out,
    output reg start_out,
    output reg [7:0] data_out
    
    );
    
    ////////////////////////////////////////
    // FAST MODULAR EXPONENTIATION MODULE //
    ////////////////////////////////////////
    
    reg fme_start;              //tick per avviare la conversione
    reg [31:0] message_in;
    reg [31:0] key;
    
    wire [31:0] message_out;
    wire fme_done;
    
    FastModExp fme_crypt (
    
        .clk        (clk),
        .rst        (rst),
        .start      (fme_start),
        
        .base       (message_in),
        .exponent   (key),
        .modulo     (n_key),
        
        .result     (message_out),
        .done       (fme_done)
    
    );
    
    //////////////////
    // DATA PACKING //
    //////////////////
    
    /*reg [4:0] n_len = 5'b0;
    reg [31:0] n_key_buf = 32'b0;
    
    always @(posedge clk) begin
        if (rst) begin
            n_key_buf <= 32'b0;
            n_len <= 5'b0;
        end
        else begin
            if (start) begin
                n_key_buf <= n_key;
                n_len <= 5'b0;
            end
            if (n_key_buf > 32'b0) begin
                n_key_buf <= n_key_buf >> 1;
                n_len <= n_len + 5'b1;                    
            end
        end
    end*/
    
    ///////////////////////////
    // ENCRYPT OPERATION FSM //
    ///////////////////////////
    
    parameter [3:0] IDLE  = 4'd0;
    parameter [3:0] START = 4'd1;
    parameter [3:0] SIZING = 4'd2;
    parameter [3:0] SEND_SIZE = 4'd3;
    parameter [3:0] PACK = 4'd4;
    parameter [3:0] PADDING = 4'd5;
    parameter [3:0] CRYPT = 4'd7;
    
    reg [3:0] state;
    reg [3:0] next_state;
    
    reg [4:0] n_len = 5'b0;
    reg [31:0] n_key_buf = 32'b0;
    
    reg [31:0] pack = 32'b0; //Shift register per contenere i dati da impacchettare
    reg [4:0]  pack_count;   //Contatore che indica quanti bit sono stati aggiunti al pacchetto
    
    assign message_in = pack;
    
    always @(posedge clk) begin
        if (rst) begin
            n_key_buf <= 32'b0;
            n_len <= 5'b0;
            pack <= 32'b0;
            pack_count <= 5'b0;
            state <= IDLE;
        end
        else
            state <= next_state;
        case (state)
            START: begin
                n_key_buf <= n_key;
                n_len <= 5'b0;
            end
            
            SIZING: begin
                if (n_key_buf > 32'b0) begin
                    n_key_buf <= n_key_buf >> 1;
                    n_len <= n_len + 5'b1;
                end
            end
            
            PACK: begin
                if (read_in) begin
                    pack <= {data_in, pack} >> 1;
                    pack_count <= pack_count + 1'b1;
                end
            end
            
            PADDING: begin
                pack <= pack >> 1;
                pack_count <= pack_count + 1'b1;
            end
        endcase
    end
    
    always @(*) begin
        case (state)
            IDLE: begin
                data_out = 8'b0;
                start_out = 1'b0;
                fme_start = 1'b0;
                
                if (start)
                    next_state = START;
                else
                    next_state = IDLE;
            end
            
            START: begin
                data_out = 8'b0;
                start_out = 1'b0;
                fme_start = 1'b0;
                
                next_state = SIZING;
            end
            
            SIZING: begin
                fme_start = 1'b0;
                if (n_key_buf > 32'b0) begin
                    data_out = 8'b0;
                    start_out = 1'b0;
                    
                    next_state = SIZING;
                end
                else begin
                    data_out = n_len;
                    start_out = 1'b1;
                    
                    next_state = SEND_SIZE;
                end
            end
            
            SEND_SIZE: begin
                data_out = n_len;
                start_out = 1'b0;
                fme_start = 1'b0;
                
                if (ready_out)
                    next_state = PACK;
                else
                    next_state = SEND_SIZE;
            end
            
            PACK: begin
                data_out = 8'b0;
                start_out = 1'b0;
                fme_start = 1'b0;
                
                if (pack_count == n_len - 5'd1)
                    next_state = PADDING;
                else
                    next_state = PACK;
            end
            
            PADDING: begin
                data_out = 8'b0;
                start_out = 1'b0;
                fme_start = 1'b0;
                
                if (pack_count == 5'd31)
                    next_state = CRYPT;
                else
                    next_state = PADDING;
            end
            
            CRYPT: begin
                data_out = 8'b0;
                start_out = 1'b0;
                fme_start = 1'b1;
                
                next_state = PACK;
            end
        endcase
    end
    
endmodule
