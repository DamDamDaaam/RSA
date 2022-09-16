`timescale 1ns / 100ps

//Riceve il cifrato dalla UART e lo carica in FastModExp, dove viene decriptato

//Ogni volta che questo modulo riceve un byte di cifrato lo shifta in un pack da 32 bit;
//quando il pack è stato riempito con una word da 4 byte la decifratura si avvia
//e si ritorna ad aspettare dati. Il tempo tra l'arrivo di un byte e l'altro è molto
//superiore alla durata del processo di decifratura della word

//Il software deve inviare a inizio comunicazione a DecrypterIn la lunghezza del cifrato
//misurata in word, poichè questa informazione viene usata per determinare
//la fine della procedura

module DecrypterIn (
    input wire clk,
    input wire rst,
    input start,
    
    input wire ready_in,
    input wire [7:0] data_in,
    
    output reg clear_rx_flag,
    
    output reg fme_start,
    output reg [31:0] fme_data_in,
    
    output reg last_word_tick
    
    );
    
    parameter IDLE = 1'b0;
    parameter LOAD = 1'b1;
    
    //Registri
    
    reg [31:0] cipher_len = 32'b0;    
    reg [31:0] word_count = 32'b0;
        
    reg [1:0]  pack_count = 2'b0;
    reg [31:0] pack = 32'b0;
    
    reg check_reg = 1'b0;
    
    reg state = IDLE;
    
    //Prossimi valori dei registri
    
    reg [31:0] next_cipher_len;
    reg [31:0] next_word_count;
    reg [31:0] next_pack;
    reg [1:0]  next_pack_count;
    reg next_check;
    reg next_state;
    
    assign fme_data_in = pack;
    
    always @(posedge clk) begin
        if (rst) begin
            cipher_len <= 32'b0;
            word_count <= 32'b0;
            pack_count <= 2'b0;
            pack <= 32'b0;
            
            check_reg <= 1'b0;
            
            state <= IDLE;
        end
        else begin
            cipher_len <= next_cipher_len;
            word_count <= next_word_count;
            pack_count <= next_pack_count;
            pack <= next_pack;
            
            check_reg <= next_check;
            
            state <= next_state;
        end
    end
    
    always @(*) begin
        clear_rx_flag = 1'b0;
        fme_start = 1'b0;
        last_word_tick = 1'b0;
        
        next_cipher_len = cipher_len;
        next_word_count = word_count;
        next_pack_count = pack_count;
        next_pack = pack;
        
        next_check = check_reg;
        
        next_state = state;
        
        case (state)
            IDLE: begin
                next_cipher_len = 32'b0;
                next_word_count = 32'b0;
                next_pack_count = 2'b0;
                next_pack = 32'b0;
                if (start) begin
                    clear_rx_flag = 1'b1;   //Per assicurare che a inizio processo sia basso ready_in
                    
                    next_state = LOAD;
                end
            end
            
            LOAD: begin
                if ((word_count == cipher_len) && (cipher_len != 32'b0)) begin   //se ha decifrato tutte le word da 32 bit...
                    last_word_tick = 1'b1;                                       //...notifica con un tick che ha caricato l'ultima word...
                    next_state = IDLE;    
                end                                         //...e va in IDLE
                if (ready_in) begin                         //se c'è un byte in ingresso...
                    clear_rx_flag = 1'b1;
                    
                    next_pack[31:8] = pack[23:0];
                    next_pack[7:0] = data_in[7:0];          //...lo shifta nel pack da destra verso sinistra...
                    next_pack_count = pack_count + 2'b1;
                    
                    next_check = 1'b1;                      //...e al prossimo clock controlla
                end
                else if (check_reg) begin
                    if (pack_count == 2'b0) begin                   //quando ha ricevuto tutta una word da 32 bit:
                        if (cipher_len == 32'b0) begin              //- se non sa ancora quanto è lungo il messaggio (prima iterazione)...
                            next_cipher_len = pack;                 //...allora la word ricevuta è il numero di word e lo salva
                            next_pack = 32'b0;
                        end
                        else begin                                  //- altrimenti la parola è da decifrare, quindi...
                            fme_start = 1'b1;                       //...avvia il decrypting...
                            next_word_count = word_count + 32'b1;   //...e conta una parola in più
                        end
                    end
                    
                    next_check = 1'b0;
                end
            end
        endcase
    end
    
endmodule
