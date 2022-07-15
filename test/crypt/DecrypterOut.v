`timescale 1ns / 100ps

module DecrypterOut (
    input wire clk,
    input wire rst,
    input wire start,
    
    input wire [31:0] n_key,
    
    input wire word_ready,    //Viene da FME e dice "Devi inviare i dati"
    input wire [31:0] data_in,
    
    input wire tx_done_tick,

    output wire sending_word, //Alta se la parola sta venendo trasmessa
    output reg  tx_start,
    output wire [7:0] data_out
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
        next_flag = flag_reg;
        tx_start = 1'b0;
        
        next_state = state;
        
        if (tx_done_tick)
            next_tx_busy = 1'b0;
        
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
            
            SHIFT: begin    //TODO: decidere come tornare in IDLE (EOT, word_count, last_word)
                if (flag_reg) begin //TODO: sostituire con pack_count < n_len sotto
                    if (pack_count == n_len - 5'b1)     //(se ha già shiftato tutte le cifre valide (ossia non di padding)...
                        next_flag = 1'b0;               //...aspetta una nuova word)
                    else begin      //TODO: invertire if(byte_count) e if(~tx_busy) per non ripetere shifting
                        if (byte_count == 3'b0) begin                               //se il byte è pronto...
                            if (~tx_busy) begin                                     //...e non se ne sta inviando un altro...
                                tx_start = 1'b1;                                    //...lo manda...
                                next_tx_busy = 1'b1;                                //...e comunica che il tx è occupato...
                                {next_pack, next_byte} = {pack_reg, byte_reg} >> 1; //...quindi shifta...
                                next_pack_count = pack_count + 5'b1;                //...e incrementa...
                                next_byte_count = byte_count + 3'b1;                //...i counter...
                            end
                        end
                        else begin
                            {next_pack, next_byte} = {pack_reg, byte_reg} >> 1;     //...altrimenti shifta e incrementa senza mandare
                            next_pack_count = pack_count + 5'b1;
                            next_byte_count = byte_count + 3'b1;
                        end
                    end
                end
                else if (word_ready) begin                              //se c'è una parola in arrivo...
                    {next_pack, next_byte} = {data_in, byte_reg} >> 1;  //...la mette nel pack e shifta di uno...
                    next_byte_count = byte_count + 3'b1;                //...incrementando il conteggio di cifre nel byte...
                    next_pack_count = 5'd1;                             //...e ponendo a 1 quello delle cifre nel pack
                    next_flag = 1'b1;                                   //...quindi si prepara a shiftare
                end
            end
            
            default:
                next_state = IDLE;
        endcase
    end
    
endmodule
