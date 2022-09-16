`timescale 1ns / 100ps

//Riceve word di cifrato da FastModExp e le invia alla UART un byte alla volta

module EncrypterOut (
    input wire clk,
    input wire rst,
    input wire tx_done_tick,
    input wire word_ready,     //Viene da FastModExp quando la word in data_in è valida
    input wire [31:0] data_in,
    output wire sending_word,  //Alta se la parola sta venendo trasmessa
    output wire tx_start,
    output wire [7:0] data_out //Byte da inviare alla UART
    );

    reg [31:0] data_buf = 32'b0; //Shift register per caricare la word nel registro
    reg [31:0] next_data_buf;    //del byte da inviare
    
    reg [1:0] byte_count = 2'b0;
    reg [1:0] next_byte_count;
    
    reg flag_reg = 1'b0;         //Registro a cui è assegnato sending_word
    reg next_flag;
    
    reg tx_start_reg;
    reg next_tx_start;
    
    reg [7:0] byte_reg = 8'b0;   //Registro del byte da inviare
    reg [7:0] next_byte;
    
    assign sending_word = flag_reg;   
    assign data_out = byte_reg;
    assign tx_start = tx_start_reg;
    
    //Blocco che aggiorna i registri ai loro prossimi valori, indicati nel blocco combinatorio
    always @(posedge clk) begin
        if (rst) begin
            data_buf <= 32'b0;
            byte_count <= 2'b0;
            flag_reg <= 1'b0;
            tx_start_reg <= 1'b0;
            byte_reg <= 8'b0;
        end
        else begin
            data_buf <= next_data_buf;
            byte_count <= next_byte_count;
            flag_reg <= next_flag;
            tx_start_reg <= next_tx_start;
            byte_reg <= next_byte;
        end
    end
    
    always @(*) begin
        next_data_buf = data_buf;
        next_byte_count = byte_count;
        next_flag = flag_reg;
        next_tx_start = 1'b0;
        next_byte = byte_reg;
        if (flag_reg) begin                 //Se l'invio della word è in corso
            if (tx_done_tick) begin         //al termine dell'invio di un byte
                if (byte_count == 2'd3)     //verifica se la word è finita:
                    next_flag = 1'b0;       //se sì torna ad attendere un'altra word;
                else
                    next_tx_start = 1'b1;   //se no manda il prossimo byte.
                next_byte = data_buf[31:24];
                next_byte_count = byte_count + 2'b1;
                next_data_buf = data_buf << 8;
            end
        end
        else if (word_ready) begin          //Se non sta inviando attende di ricevere una word,
            next_byte = data_in[31:24];
            next_data_buf = data_in << 8;   //inizia a shiftarla nel data_buf
            next_tx_start = 1'b1;           //e avvia l'invio del primo byte
            next_flag = 1'b1;
        end
    end
    
endmodule
