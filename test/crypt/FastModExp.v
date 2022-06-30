
`timescale 1ns / 100ps

module FastModExp (
    
    input wire clk,
    input wire rst,
    input wire start,
    
    input wire [31:0] base,
    input wire [31:0] exponent,
    input wire [31:0] modulo,
    
    output reg [31:0] result,
    output reg done
    
    );
    
    reg [31:0] mult1;
    reg [31:0] mult2;
    wire [63:0] product;
    
    Multiplier_32 fme_mult (
        .CLK(clk),
        
        .A(mult1),
        .B(mult2),
        
        .P(product)
    );
    
    reg div_en;  //DA RIVEDERE
    wire div_done;
    wire [95:0] div_out;
    wire [31:0] remainder;
    
    assign remainder[31:0] = div_out[31:0];
    
    always @(*)
        if (product == 64'b0)
            div_en = 1'b0;
        else
            div_en = 1'b1;
    
    Divider64_32 fme_div (
        .aclk                   (clk),
        .aresetn                (~rst),
        
        .s_axis_divisor_tvalid  (div_en),           //DA RIVEDERE
        .s_axis_divisor_tdata   (modulo),
        
        .s_axis_dividend_tvalid (div_en),           //DA RIVEDERE
        .s_axis_dividend_tdata  (product),
        
        .m_axis_dout_tvalid     (div_done),
        .m_axis_dout_tdata      (div_out)
    );
    
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
                
                if (waitCounter == 7'd70)
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
