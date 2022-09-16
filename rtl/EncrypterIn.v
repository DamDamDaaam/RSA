`timescale 1ns / 100ps

//Riceve il messaggio dalla UART e lo carica in FastModExp, dove viene criptato

//I byte ricevuti vengono caricati un bit alla volta da sinistra in uno shift register,
//partendo dal loro LSB.
//Una volta caricati (n_len - 1) bit, la word viene portata alla dimensione di 32 bit
//aggiungendo zeri di padding a sinistra, e viene inviata a FastModExp

module EncrypterIn (
    input wire clk,
    input wire rst,
    input wire start,
    
    input wire [31:0] n_key,
    
    input wire eot_in,
    input wire ready_in,
    input wire [7:0] data_in,
    
    output reg clear_rx_flag,
    
    output reg start_out,
    output reg [7:0] n_len_out,
    
    output reg fme_start,
    output reg [31:0] fme_data_in
    );
    
    parameter [1:0] IDLE    = 2'd0;
    parameter [1:0] SIZING  = 2'd1; //Calcolo e invio della lunghezza della chiave n
    parameter [1:0] PACK    = 2'd2; //Caricamento di (n_len - 1) bit validi nello shift register
    parameter [1:0] PADDING = 2'd3; //Aggiunta degli zeri di padding e invio a FastModExp
    
    //Registri
    
    reg [1:0] state;
    
    reg [4:0]  n_len = 5'b0;
    reg [31:0] n_key_buf = 32'b0;
    
    reg [2:0]  byte_count = 3'b0;
    reg [7:0]  data_buf = 8'b0; //Qui si bufferizzano i byte in ingresso, per shiftarli in pack
    
    reg [4:0]  pack_count = 5'b0;
    reg [31:0] pack = 32'b0;    //Shift register per contenere i dati da impacchettare
    
    reg eot_received = 1'b0;
    
    //Variabili combinatorie per determinare i prossimi valori dei registri
    
    reg [1:0] next_state;
    reg [4:0]  next_n_len;
    reg [31:0] next_n_key;
    reg [2:0]  next_byte_count;
    reg [7:0]  next_data;
    reg [4:0]  next_pack_count;
    reg [31:0] next_pack;
    reg next_eot_received;
    
    assign fme_data_in = pack;
    assign n_len_out = n_len;
    
    always @(posedge clk) begin
        if (rst) begin
            n_key_buf <= 32'b0;
            n_len <= 5'b0;
            byte_count <= 3'b0;
            data_buf <= 8'b0;
            pack_count <= 5'b0;
            pack <= 32'b0;
            eot_received <= 1'b0;
            
            state <= IDLE;
        end
        else begin
            n_key_buf <= next_n_key;
            n_len <= next_n_len;
            byte_count <= next_byte_count;
            data_buf <= next_data;
            pack_count <= next_pack_count;
            pack <= next_pack;
            eot_received <= next_eot_received;
            
            state <= next_state;
        end
    end
    
    always @(*) begin
        start_out = 1'b0;
        fme_start = 1'b0;
        clear_rx_flag = 1'b0;
        
        next_n_len = n_len;
        next_n_key = n_key_buf;
        next_byte_count = byte_count;
        next_data = data_buf;
        next_pack_count = pack_count;
        next_pack = pack;
        next_eot_received = eot_received;
        
        next_state = state;
        
        case (state)
            IDLE: begin
                next_n_len = 5'b0;
                next_n_key = n_key;
                if (start) begin
                    clear_rx_flag = 1'b1; //Assicura che a inizio processo sia basso ready_in
                    
                    next_state = SIZING;
                end
            end
            
            SIZING: begin
                if (n_key_buf > 32'b0) begin     //Calcola n_len shiftando la chiave finchè non
                    next_n_len = n_len + 5'b1;   //diventa uguale a zero e contando i passaggi,
                    next_n_key = n_key_buf >> 1;
                end
                else begin
                    start_out = 1'b1;            //poi invia il valore ottenuto sulla UART
                    
                    next_pack_count = 5'b0;
                    next_byte_count = 3'b0;
                    next_pack = 32'b0;
                    next_data = 8'b0;
                    
                    next_state = PACK;
                end
            end
            
            PACK: begin
                if ((pack_count == n_len - 5'd1))       //Se tutti i bit validi della word sono stati aggiunti al pack
                    next_state = PADDING;               //passa ad aggiungere il padding
                else begin
                    if (byte_count == 3'b0) begin       //Se un intero byte è stato shiftato nel pack
                        if (eot_in) begin               //verifica se il messaggio è finito:
                            clear_rx_flag = 1'b1;
                            next_eot_received = 1'b1;   //se sì setta una flag
                            next_state = PADDING;       //e si prepara ad aggiungere padding e inviare ciò che resta;
                        end
                        else if (ready_in) begin        //se no aspetta un nuovo byte dalla UART e inizia a caricarlo nel pack
                            clear_rx_flag = 1'b1;
                            next_byte_count = byte_count + 3'b1;
                            next_pack_count = pack_count + 5'b1;
                            {next_data, next_pack} = {data_in, pack} >> 1;
                        end
                    end
                    else begin                                           //Se invece ci sono ancora bit da shiftare nel byte corrente
                        next_byte_count = byte_count + 3'b1;             //li shifta uno a uno
                        next_pack_count = pack_count + 5'b1;
                        {next_data, next_pack} = {data_buf, pack} >> 1;
                    end
                end
            end
            
            PADDING: begin
                if (pack_count == 5'd0) begin         //Se sono stati aggiunti abbastanza zeri per avere una word da 32 bit
                    fme_start = 1'b1;                 //avvia la cifratura,
                    if (eot_received) begin           //poi verifica se il messaggio è finito:
                        next_eot_received = 1'b0;
                        next_state = IDLE;            //se sì termina il processo;
                    end
                    else
                        next_state = PACK;            //se no va a costruire la prossima word
                end
                else begin
                    next_pack_count = pack_count + 5'b1;
                    next_pack = pack >> 1;                //Aggiunge uno zero di padding
                end
            end
        endcase
    end

endmodule
