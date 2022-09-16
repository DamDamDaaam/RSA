`timescale 1ns / 100ps

//Elabora le word da 32 bit prodotte da FastModExp per riformare e trasmettere via UART
//il messaggio in chiaro.

//In fase di cifratura le word erano ottenute aggiungendo a un pack di (n_len - 1) bit
//un padding di zeri fino a raggiungere la dimensione di 32 bit, quindi qui avviene l'opposto:
//di ogni word vengono inviati tramite UART solo i primi (n_len - 1) bit, scartando il padding.

//Per determinare quando l'intero messaggio è stato decifrato si usano due flag:
//last_word_reg e almost_done_reg.
//La prima si alza quando si riceve notifica da DecrypterIn che l'ultima word è in decifratura,
//la seconda quando detta decifratura termina e quindi l'ultima word raggiunge DecrypterOut.
//Infine il processo termina quando l'ultima word è stata spacchettata e inviata

module DecrypterOut (
    input wire clk,
    input wire rst,
    input wire start,
    
    input wire [31:0] n_key,
    
    input wire word_ready,     //Viene da FME e dice "Devi inviare i dati"
    input wire [31:0] data_in,
    
    input wire last_word_tick, //Viene da DecrypterIn quando l'ultima word entra in FME
    
    input wire tx_done_tick,

    output wire sending_word,  //Alta se la parola sta venendo trasmessa
    output reg  tx_start,
    output wire [7:0] data_out,
    
    output reg done_tick       //Emesso quando la decrittografia è interamente completata
    );
    
    //Definizione stati FSM
    
    parameter [1:0] IDLE    = 2'd0;
    parameter [1:0] SIZING  = 2'd1;
    parameter [1:0] SHIFT   = 2'd2;
    
    //Registri
    
    reg [1:0] state;
    
    reg [31:0] n_key_buf = 32'b0;
    reg [4:0]  n_len = 5'b0;
    
    reg [31:0] pack_reg = 32'b0;
    reg [4:0]  pack_count = 5'b0;
    
    reg [7:0] byte_reg = 8'b0;
    reg [2:0] byte_count = 3'b0;
    
    reg tx_busy = 1'b0;
    reg last_word_reg = 1'b0;
    reg almost_done_reg = 1'b0;
    reg flag_reg = 1'b0;
    
    assign sending_word = flag_reg;
    assign data_out = byte_reg;
    
    //Prossimi valori dei registri
    
    reg [1:0]  next_state;
    reg [31:0] next_n_key;
    reg [4:0]  next_n_len;
    reg [31:0] next_pack;
    reg [4:0]  next_pack_count;
    reg [7:0]  next_byte;
    reg [2:0]  next_byte_count;
    reg next_tx_busy;
    reg next_last_word;
    reg next_almost_done;
    reg next_flag;
    
    always @(posedge clk) begin
        if (rst) begin
            n_key_buf <= 32'b0;
            n_len <= 5'b0;
            pack_reg <= 32'b0;
            pack_count <= 5'b0;
            byte_reg <= 8'b0;
            byte_count <= 3'b0;
            tx_busy <= 1'b0;
            last_word_reg <= 1'b0;
            almost_done_reg <= 1'b0;
            flag_reg <= 1'b0;
            
            state <= IDLE;
        end
        else begin
            n_key_buf <= next_n_key;
            n_len <= next_n_len;
            pack_reg <= next_pack;
            pack_count <= next_pack_count;
            byte_reg <= next_byte;
            byte_count <= next_byte_count;
            tx_busy <= next_tx_busy;
            last_word_reg <= next_last_word;
            almost_done_reg <= next_almost_done;
            flag_reg <= next_flag;
            
            state <= next_state;
        end
    end
    
    always @(*) begin
        next_n_key = n_key_buf;
        next_n_len = n_len;
        next_pack = pack_reg;
        next_pack_count = pack_count;
        next_byte = byte_reg;
        next_byte_count = byte_count;
        next_tx_busy = tx_busy;
        next_last_word = last_word_reg;
        next_almost_done = almost_done_reg;
        done_tick = 1'b0;
        next_flag = flag_reg;
        tx_start = 1'b0;
        
        next_state = state;
        
        if (tx_done_tick)
            next_tx_busy = 1'b0;
        
        if (last_word_tick)
            next_last_word = 1'b1;
        
        case (state)
            IDLE: begin
                next_n_len = 5'b0;
                next_n_key = n_key;
                if (start)
                    next_state = SIZING;
            end
            
            SIZING: begin       //determina la lunghezza di n_key per il packing
                if (n_key_buf > 32'b0) begin
                    next_n_len = n_len + 5'b1;
                    next_n_key = n_key_buf >> 1;
                end
                else begin
                    next_pack_count = 5'b0;
                    next_byte_count = 3'b0;
                    next_pack = 32'b0;
                    next_byte = 8'b0;
                    
                    next_state = SHIFT;
                end
            end
            
            SHIFT: begin
                if (flag_reg) begin
                    if (byte_count == 3'b0) begin                                   //Se c'è un byte pronto per essere mandato
                        if (~tx_busy) begin                                         //si aspetta che il canale sia libero
                            tx_start = 1'b1;                                        //e lo si manda,
                            next_tx_busy = 1'b1;
                            if (pack_count == n_len - 5'b1)                         //poi se tutti i bit non di padding sono stati inviati
                                next_flag = 1'b0;                                   //si torna ad attendere una word da FME
                            else begin                                              //se invece ci sono ancora bit non di padding da inviare
                                {next_pack, next_byte} = {pack_reg, byte_reg} >> 1; //si ricomincia a shiftare.
                                next_pack_count = pack_count + 5'b1;
                                next_byte_count = byte_count + 3'b1;
                            end
                        end
                    end
                    else if (pack_count == n_len - 5'b1)                            //Altrimenti, se tutti i bit non di padding sono stati shiftati
                        next_flag = 1'b0;                                           //si torna ad attendere una word da FME
                    else begin                                                      //Infine, se il byte non è pronto E il pack non è svuotato
                        {next_pack, next_byte} = {pack_reg, byte_reg} >> 1;         //si shifta e basta.
                        next_pack_count = pack_count + 5'b1;
                        next_byte_count = byte_count + 3'b1;
                    end
                end
                else if (word_ready) begin                              //se c'è una parola in arrivo...
                    {next_pack, next_byte} = {data_in, byte_reg} >> 1;  //...la mette nel pack e shifta di uno...
                    next_byte_count = byte_count + 3'b1;                //...incrementando il conteggio di cifre nel byte...
                    next_pack_count = 5'd1;                             //...e ponendo a 1 quello delle cifre nel pack
                    next_flag = 1'b1;                                   //...quindi si prepara a shiftare.
                    if (last_word_reg) begin                            //Se inoltre la parola è l'ultima...
                        next_last_word = 1'b0;                          //...resetta la flag di ultima parola...
                        next_almost_done = 1'b1;                        //...e alza la flag di "quasi finito".
                    end
                end
                else if (almost_done_reg) begin            //Altrimenti, se la flag di "quasi finito" è alta
                    done_tick = 1'b1;                      //la procedura termina,
                    next_almost_done = 1'b0;               //si resetta la flag
                    
                    next_state = IDLE;                     //e si torna in IDLE
                end
            end
            
            default:
                next_state = IDLE;
        endcase
    end
    
endmodule
