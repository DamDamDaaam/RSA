`timescale 1ns / 100ps

module WordToBytes (
    input wire clk,
    input wire rst,
    input wire tx_busy,       //Viene dalla flag di UART_TX_Interface, dice "Pronto a inviare"
    input wire tx_done_tick,
    input wire word_ready,    //Viene da Crypter e dice "Devi inviare i dati"
    input wire [31:0] data_in,
    output wire sending_word, //Alta se la parola sta venendo trasmessa
    output wire tx_start,
    output wire [7:0] data_out
    );

    reg [31:0] data_buf = 32'b0;
    reg [31:0] next_data_buf;
    
    reg [1:0] byte_count = 2'b0;
    reg [1:0] next_byte_count;
    
    reg flag_reg = 1'b0;
    reg next_flag;
    
    reg tx_start_reg;
    reg next_tx_start;
    
    reg [7:0] byte_reg = 8'b0;
    reg [7:0] next_byte;
    
    assign sending_word = flag_reg;   
    assign data_out = byte_reg;
    assign tx_start = tx_start_reg;
    
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
        if (flag_reg) begin //if (sending_word)
            if (tx_done_tick) begin
                if (byte_count == 2'd3)
                    next_flag = 1'b0;
                else
                    next_tx_start = 1'b1;
                next_byte = data_buf[31:24];
                next_byte_count = byte_count + 2'b1;
                next_data_buf = data_buf << 8;
            end
        end
        else if (word_ready) begin
            next_byte = data_in[31:24];
            next_data_buf = data_in << 8;
            next_tx_start = 1'b1;
            next_flag = 1'b1;
        end
    end
    
endmodule
