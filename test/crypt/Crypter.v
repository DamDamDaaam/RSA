
`timescale 1ns / 100ps

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
    
    reg [4:0] n_len = 5'b0;
    reg [31:0] n_key_buf = 32'b0;
    
    always @(posedge clk) begin
        if (rst) begin
            n_key_buf <= 32'b0;
            n_len <= 5'b0;
        end
        else begin
            if (start) begin
                n_key_buf <= n_key;
            end
            if (n_key_buf > 32'b0) begin
                n_key_buf <= n_key_buf >> 1;
                n_len <= n_len + 5'b1;                    
            end
        end
    end
    
    ////////////////////////
    // FAST MOD EXP - FSM //
    ////////////////////////
    
    parameter [2:0] IDLE   = 3'h0;
    parameter [2:0] START  = 3'h1;
    parameter [2:0] MULT_R = 3'h2;
    parameter [2:0] MULT_A = 3'h3;
    parameter [2:0] WAIT   = 3'h4;
    parameter [2:0] SAVE_R = 3'h5;
    parameter [2:0] SAVE_A = 3'h6;
    parameter [2:0] DONE   = 3'h7;
    
    reg [2:0] state;
    reg [2:0] next_state;
    
    reg [31:0] a_tmp;
    reg [31:0] r_tmp;
    reg [31:0] n_tmp;
    
    reg [31:0] nxt_n;
    reg [6:0] waitCounter;
    
    always @(posedge clk) begin
        if (rst) begin
            a_tmp <= 32'h0;
            r_tmp <= 32'h0;
            n_tmp <= 32'h0;
            waitCounter <= 7'h0;
            state <= IDLE;
        end
        else begin
            if (state == START) begin
                a_tmp <= base;
                n_tmp <= exponent;
                r_tmp <= 32'h1;
            end
            else if (state == MULT_A) begin
                n_tmp <= nxt_n;
                waitCounter <= 7'h0;
            end
            else if (state == WAIT) begin
                waitCounter <= waitCounter + 7'h1;
            end
            else if (state == SAVE_R) begin
                r_tmp <= remainder;
            end
            else if (state == SAVE_A) begin
                a_tmp <= remainder;
            end

            state <= next_state;
        end
    end
    
    always @(*) begin
        case (state)
            IDLE: begin
                mult1 = 32'b0;
                mult2 = 32'b0;
                
                nxt_n = 32'b0;
                
                result = 32'b0;
                done = 1'b0;
                
                if (start) begin
                    next_state = START;
                end
                else begin
                    next_state = IDLE;
                end
            end
            
            START: begin
                mult1 = 32'b0;
                mult2 = 32'b0;
                
                nxt_n = 32'b0;

                result = 32'b0;
                done = 1'b0;
                
                next_state = MULT_R;
            end

            MULT_R: begin
                mult1 = r_tmp;

                nxt_n = 32'b0;

                result = 32'b0;
                done = 1'b0;
                
                if (n_tmp[0] == 1'b1) begin
                    mult2 = a_tmp;
                end
                else begin
                    mult2 = 32'b1;
                end
                
                next_state = MULT_A;
            end
            
            MULT_A: begin
                mult1 = a_tmp;
                mult2 = a_tmp;
                
                nxt_n[31] = 1'b0;
                nxt_n[30:0] = n_tmp[31:1];

                result = 32'b0;
                done = 1'b0;
                
                next_state = WAIT;
            end
            
            WAIT: begin
                mult1 = 32'b0;
                mult2 = 32'b0;
                
                nxt_n = 32'b0;

                result = 32'b0;
                done = 1'b0;
                
                if (waitCounter == 7'd70)  //VERIFICARE
                    next_state = SAVE_R;
                else
                    next_state = WAIT;
            end
            
            SAVE_R: begin
                mult1 = 32'b0;
                mult2 = 32'b0;
                
                nxt_n = 32'b0;

                result = 32'b0;
                done = 1'b0;
                
                next_state = SAVE_A;
            end
            
            SAVE_A: begin
                mult1 = 32'b0;
                mult2 = 32'b0;
                
                nxt_n = 32'b0;

                result = 32'b0;
                done = 1'b0;
                
                if(n_tmp == 32'b0)
                    next_state = DONE;
                else
                    next_state = MULT_R;
            end
            
            DONE: begin
                mult1 = 32'b0;
                mult2 = 32'b0;
                
                nxt_n = 32'b0;

                result = r_tmp;
                done = 1'b1;
                
                next_state = IDLE;
            end
            
        endcase
    end
    
endmodule