`timescale 1ns / 100ps

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
    parameter [1:0] SIZING  = 2'd1;
    parameter [1:0] PACK    = 2'd2;
    parameter [1:0] PADDING = 2'd3;
    
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
                clear_rx_flag = 1'b1; //Per assicurare che a inizio processo sia basso ready_in
                next_n_len = 5'b0;
                next_n_key = n_key;
                if (start)
                    next_state = SIZING;
            end
            
            SIZING: begin
                if (n_key_buf > 32'b0) begin
                    next_n_len = n_len + 5'b1;
                    next_n_key = n_key_buf >> 1;
                end
                else begin
                    start_out = 1'b1;
                    
                    next_pack_count = 5'b0;
                    next_byte_count = 3'b0;
                    next_pack = 32'b0;
                    next_data = 8'b0;
                    
                    next_state = PACK;
                end
            end
            
            PACK: begin
                if ((pack_count == n_len - 5'd1))
                    next_state = PADDING;
                else begin
                    if (byte_count == 3'b0) begin
                        if (eot_in) begin
                            clear_rx_flag = 1'b1;
                            next_eot_received = 1'b1;
                            next_state = PADDING;
                        end
                        else if (ready_in) begin
                            clear_rx_flag = 1'b1;
                            next_byte_count = byte_count + 3'b1;
                            next_pack_count = pack_count + 5'b1;
                            {next_data, next_pack} = {data_in, pack} >> 1;
                        end
                    end
                    else begin
                        next_byte_count = byte_count + 3'b1;
                        next_pack_count = pack_count + 5'b1;
                        {next_data, next_pack} = {data_buf, pack} >> 1;
                    end
                end
            end
            
            PADDING: begin
                if (pack_count == 5'd0) begin
                    fme_start = 1'b1;
                    if (eot_received) begin
                        next_eot_received = 1'b0;
                        next_state = IDLE;
                    end
                    else
                        next_state = PACK;
                end
                else begin
                    next_pack_count = pack_count + 5'b1;
                    next_pack = pack >> 1; 
                end
            end
        endcase
    end

endmodule
