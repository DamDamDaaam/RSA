`timescale 1ns / 100ps

//Modulo che esegue le operazioni di cifratura e decifratura tramite l'algoritmo FME.
//Le word che vengono cifrate/decifrate sono da 32 bit. Il valore di result varia durante il
//calcolo, e deve essere considerato solo durante il ciclo di clock in cui done è alto

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
    
    /////////////////////////////////
    // PARALLEL MULTIPLIER IP CORE //
    /////////////////////////////////
    
    reg [31:0] mult1;
    reg [31:0] mult2;
    wire [63:0] product;
    
    Multiplier_32 fme_mult (
        .CLK(clk),
        
        .A(mult1),
        .B(mult2),
        
        .P(product)
    );
    
    //////////////////////////////////////////////////////////
    // SHIFT REGISTER PER SEGNALARE TERMINE MOLTIPLICAZIONE //
    //////////////////////////////////////////////////////////
    
    reg mult_start;
    reg [6:0] mult_shift;
    
    always @(posedge clk) begin
        if (rst)
            mult_shift <= 7'b0;
        else begin
            mult_shift[0] <= mult_start;
            for (integer i = 1; i < 7; i = i + 1) begin
                mult_shift[i] <= mult_shift[i - 1];
            end
        end
    end
    
    /////////////////////////////////////////////
    // DIVIDER Radix-2 CON DIVIDENDO DA 64 BIT //
    /////////////////////////////////////////////
    
    wire div_en;
    wire div_done;
    wire [95:0] div_out;
    wire [31:0] remainder;
    
    assign div_en = mult_shift[6];
    assign remainder[31:0] = div_out[31:0];
    
    DividerRadix2_64_32 fme_div (
        .aclk                   (clk),
        .aresetn                (~rst),
        
        .s_axis_divisor_tvalid  (div_en),
        .s_axis_divisor_tdata   (modulo),
        
        .s_axis_dividend_tvalid (div_en),
        .s_axis_dividend_tdata  (product),
        
        .m_axis_dout_tvalid     (div_done),
        .m_axis_dout_tdata      (div_out)
    );
    
    ////////////////////////
    // FAST MOD EXP - FSM //
    ////////////////////////
    
    parameter [2:0] IDLE   = 3'd0;
    parameter [2:0] MULT_R = 3'd1; //Avvia la moltiplicazione r * a (o r * 1 se n[0] = 0)
    parameter [2:0] MULT_A = 3'd2; //Avvia la moltiplicazione a * a (da fare sempre)
    parameter [2:0] SAVE_R = 3'd3; //Salva il primo risultato in r
    parameter [2:0] SAVE_A = 3'd4; //Salva il secondo risultato in a
    
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
    
    assign result = r_tmp;
    
    always @(posedge clk) begin
        if (rst) begin
            a_tmp <= 32'h0;
            r_tmp <= 32'h0;
            n_tmp <= 32'h0;
            
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
        mult_start = 1'b0;
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
                mult_start = 1'b1;
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
                mult_start = 1'b1;
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
                
                if(n_tmp == 32'b0) begin //Quando n = 0 vuol dire che la chiave è stata
                    done = 1'b1;         //completamente shiftata, quindi termina
                    
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
