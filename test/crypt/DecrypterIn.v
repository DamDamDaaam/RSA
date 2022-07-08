`timescale 1ns / 100ps

module DecrypterIn (
    input wire clk,
    input wire rst,
    input start,
    
    input wire ready_in,
    input wire [7:0] data_in,
    
    output reg clear_rx_flag,
    
    output reg fme_start,
    output reg [31:0] fme_data_in
    );
    
    parameter IDLE = 1'b0;
    parameter LOAD = 1'b1;
    
    //Registri
    
    reg [31:0] cipher_len = 32'b0;    
    reg [31:0] word_count = 32'b0;
        
    reg [1:0]  pack_count = 2'b0;
    reg [31:0] pack = 32'b0;
    
    reg state = IDLE;
    
    //Prossimi valori dei registri
    
    reg [31:0] next_cipher_len;
    reg [31:0] next_word_count;
    reg [31:0] next_pack;
    reg [1:0]  next_pack_count;
    reg next_state;
    
    assign fme_data_in = pack;
    
    always @(posedge clk) begin
        if (rst) begin
            cipher_len <= 32'b0;
            word_count <= 32'b0;
            pack_count <= 2'b0;
            pack <= 32'b0;
            
            state <= IDLE;
        end
        else begin
            cipher_len <= next_cipher_len;
            word_count <= next_word_count;
            pack_count <= next_pack_count;
            pack <= next_pack;
            
            state <= next_state;
        end
    end
    
    always @(*) begin
        clear_rx_flag = 1'b0;
        fme_start = 1'b0;
        
        next_cipher_len = cipher_len;
        next_pack_count = pack_count;
        next_pack = pack;
        
        next_state = state;
        
        case (state)
            IDLE: begin
                clear_rx_flag = 1'b1;   //Per assicurare che a inizio processo sia basso ready_in
                next_cipher_len = 32'b0;
                next_word_count = 32'b0;
                next_pack_count = 2'b0;
                next_pack = 32'b0;
                if (start)
                    next_state = LOAD;
            end
            
            LOAD: begin
                if ((word_count == cipher_len) && (cipher_len != 32'b0))
                    next_state = IDLE;
                if (ready_in) begin
                    clear_rx_flag = 1'b1;
                    
                    next_pack[31:8] = pack[23:0];
                    next_pack[7:0] = data_in[7:0];
                    next_pack_count = pack_count + 2'b1;
                    
                    if (pack_count == 2'b0) begin
                        if (cipher_len == 32'b0)
                            next_cipher_len = pack;
                        else begin
                            fme_start = 1'b1;
                            next_word_count = word_count + 32'b1;
                        end
                    end
                end
            end
        endcase
    end
    
endmodule
