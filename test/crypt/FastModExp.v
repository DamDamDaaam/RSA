
`timescale 1ns / 100ps

module FastModExp (
    
    input wire clk,
    input wire rst,
    input wire start,
    
    input wire [31:0] base,
    input wire [31:0] exponent,
    input wire [31:0] modulo,
    
    output wire [31:0] result,
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
    
    DividerRadix2_64_32 fme_div (
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
    
    parameter [2:0] IDLE   = 3'd0;
    parameter [2:0] MULT_R = 3'd1;
    parameter [2:0] MULT_A = 3'd2;
    parameter [2:0] SAVE_R = 3'd3;
    parameter [2:0] SAVE_A = 3'd4;
    
    //Registri
    
    reg [2:0] state;
    
    reg [31:0] a_tmp;
    reg [31:0] r_tmp;
    reg [31:0] n_tmp;
    
    //Prossimi valori dei registri
    
    reg [31:0] next_a;
    reg [31:0] next_r;
    reg [31:0] next_n;
    reg [2:0]  next_state;
    
    //reg [6:0] waitCounter;
    
    assign result = r_tmp;
    
    always @(posedge clk) begin
        if (rst) begin
            a_tmp <= 32'h0;
            r_tmp <= 32'h0;
            n_tmp <= 32'h0;
          //waitCounter <= 7'h0;
            state <= IDLE;
        end
        else begin
            a_tmp <= next_a;
            r_tmp <= next_r;
            n_tmp <= next_n;
            state <= next_state;
        end
    end
    
    always @(*) begin
        mult1 = 32'b0;
        mult2 = 32'b0;
        done = 1'b0;
        next_a = a_tmp;
        next_r = r_tmp;
        next_n = n_tmp;
        
        next_state = state;
        
        case (state)
            IDLE: begin
                if (start) begin
                    next_a = base;
                    next_r = 32'b1;
                    next_n = exponent;
                    
                    next_state = MULT_R;
                end
            end
            
            MULT_R: begin
                mult1 = r_tmp;
                
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
                
                next_n = n_tmp >> 1;
                
                next_state = SAVE_R;
            end
            
            SAVE_R: begin
                if (div_done) begin
                    next_r = remainder;
                
                    next_state = SAVE_A;
                end
            end
            
            SAVE_A: begin
                next_a = remainder;
                
                if(n_tmp == 32'b0) begin
                    done = 1'b1;
                    
                    next_state = IDLE;
                end
                else
                    next_state = MULT_R;
            end
            
            default:
                next_state = IDLE;
        endcase
    end
    
endmodule
