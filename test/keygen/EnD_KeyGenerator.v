`timescale 1ns / 100ps

module EnD_KeyGenerator(
    
    input wire clk,
    input wire rst,
    input wire en,            //Collegato al valid di phi
    input wire [31:0] phi,
    input wire [31:0] rng_e,
    output wire e_key_valid,
    output reg [31:0] e_key,
    output wire d_key_valid,
    output reg [31:0] d_key,
    output reg rng_en
    );
    
    wire [97:0] tickets_in;
    
    reg signed [32:0] t1_ticket_in;       //Input del divider
    reg signed [32:0] t2_ticket_in;       //Input del divider
    reg [31:0] e_ticket_in;               //Input del divider
    
    assign tickets_in = {t1_ticket_in, t2_ticket_in, e_ticket_in};
    
    wire [129:0] tickets_out;       //Dati passati attraverso i tuser di EuclidDivider
    
    wire signed [32:0] t1_ticket_out;      //Valore di t1 per ExtendedEuclid
    wire signed [32:0] t2_ticket_out;      //Valore di t2 per ExtendedEuclid
    wire [31:0] e_ticket_out;              //Valore iniziale del dividendo (potenziale e_key)
    wire [31:0] divisor_ticket;            //Valore del divisore necessario durante lo swap
    
    assign t1_ticket_out  = tickets_out[129:97];
    assign t2_ticket_out  = tickets_out[96:64];
    assign e_ticket_out   = tickets_out[63:32];
    assign divisor_ticket = tickets_out[31:0];
    
    wire [63:0] data_out; //uscita di EuclidDivider
    wire [31:0] remainder;
    wire [31:0] quotient;  
    
    assign quotient  = data_out[63:32];
    assign remainder = data_out[31:0];
    
    wire steady_state;    //tvalid dell'output di EuclidDivider
    reg [31:0] dividend;
    reg [31:0] divisor;
    reg keys_valid;
    
    assign e_key_valid = keys_valid;
    assign d_key_valid = keys_valid;
    
    assign div_tvalid = en & (~keys_valid);
    
    wire signed [32:0] product;
    
    /////////////////////////////
    // DIVIDER Radix-2 IP CORE //  (latenza 35 clk, throughput 1 clk/div)
    /////////////////////////////
    
    Divider_tuser98_32 end_kg_divider (
        .aclk                   (clk ),
        .aresetn                (~rst),
        
        .s_axis_divisor_tvalid  (div_tvalid  ),
        .s_axis_divisor_tuser   (divisor     ),
        .s_axis_divisor_tdata   (divisor     ),
        
        .s_axis_dividend_tvalid (div_tvalid  ),
        .s_axis_dividend_tuser  (tickets_in  ),
        .s_axis_dividend_tdata  (dividend    ),
        
        .m_axis_dout_tvalid     (steady_state),
        .m_axis_dout_tuser      (tickets_out ),
        .m_axis_dout_tdata      (data_out    )
    );
    
    /////////////////////////////////
    // MULTIPLIER Parallel IP CORE //  (latenza 7 clk, throughput 1 clk/div)
    /////////////////////////////////
    
    Multiplier33_32 end_kg_multiplier (
        .CLK    (clk),
        
        .A      (t2_ticket_out),
        .B      (quotient     ),
        
        .P      (product      )
    );
    
    ///////////////////////////////////
    // SHIFT REGISTER per MULTIPLIER //  (latenza 7 clk)
    ///////////////////////////////////
    
    // DA VALUTARE rom_style block SE NECESSARIO PER OTTIMIZZARE AREA
    reg [161:0] shift [6:0];
    
    always @(posedge clk) begin
        for(integer i = 0; i < 6; i = i+1) begin
            shift[i] <= shift[i+1];
        end
        shift[6] <= {remainder, t1_ticket_out, t2_ticket_out, e_ticket_out, divisor_ticket};
    end
    
    wire [161:0] tickets_shift;
    wire [31:0] remainder_shift;
    wire signed [32:0] t1_ticket_shift;
    wire signed [32:0] t2_ticket_shift;
    wire [31:0] e_ticket_shift;
    wire [31:0] divisor_ticket_shift;
    
    assign tickets_shift        = shift[0];
    assign remainder_shift      = tickets_shift[161:130];
    assign t1_ticket_shift      = tickets_shift[129:97];
    assign t2_ticket_shift      = tickets_shift[96:64];
    assign e_ticket_shift       = tickets_shift[63:32];
    assign divisor_ticket_shift = tickets_shift[31:0];
    
    
    ////////////////
    // SUBTRACTOR //
    ////////////////
    
    /*reg [32:0] t_value;
    
    always @(posedge clk) begin
        t_value <= t1_ticket_shift - product; //Forse problema: potrebbe prendere il product
                                              //precedente a quello giusto
    end*/
        
    ///////////////////////////////////////////////////
    // COMBINATIONAL EXTENDED EUCLID ALGORITHM LOGIC //
    ///////////////////////////////////////////////////
    
    always @(*) begin
        if (rst) begin
            dividend    = 32'b0;
            divisor     = 32'b0;
            e_ticket_in = 32'b0;
            
            rng_en      = 1'b0;
            
            keys_valid  = 1'b0;
            e_key       = 32'b0;            
            d_key       = 32'b0;
            
            t1_ticket_in = 33'b0;
            t2_ticket_in = 33'b0;
        end
        else if (steady_state) begin   //Se la pipeline del divider è piena:
            case (remainder_shift)
                32'b0: begin              //Se trovato GCD =/= 1
                    dividend    = phi;
                    if (rng_e >= phi)     //ma rng_e è più grande di phi
                        divisor = 32'b1;  //allora scarta il dato al prossimo giro;
                    else                  //se invece rng_e è minore di phi
                        divisor = rng_e;  //fallo entrare
                    e_ticket_in = rng_e;
                    
                    rng_en      = 1'b1;   //e abilita l'LFSR.
                    
                    keys_valid = 1'b0;
                    e_key       = 32'b0;   
                    d_key       = 32'b0;
                    
                    t1_ticket_in = 33'b0;
                    t2_ticket_in = 33'd1;
                end
                
                32'b1: begin                     //Se trovato GCD == 1
                    dividend    = 32'h0;         
                    divisor     = 32'h0;         //non ha importanza cosa mando al divider
                    e_ticket_in = 32'h0;         //perchè tanto la procedura è finita;
                    
                    rng_en      = 1'b0;
                    
                    keys_valid  = 1'b1;             //segnala che la chiave è valida
                    e_key       = e_ticket_shift;  //e mandala in output al modulo.
                    /*if(t_value[32])                 // DA VALUTARE se inserire nel sincronizzatore
                        d_key   = phi + t_value;    // per avere la somma già pronta al posedge
                    else                            // di d_valid
                    d_key   = t_value;*/
                    if (t1_ticket_shift < product)
                        d_key = phi + t1_ticket_shift - product;
                    else
                        d_key = t1_ticket_shift - product;
                    t1_ticket_in = 33'b0;
                    t2_ticket_in = 33'b0;
                end
                
                default: begin                      //Se GCD non trovato
                    dividend    = divisor_ticket_shift;   //sostituisci dividendo con divisore
                    divisor     = remainder_shift;        //e divisore con resto (Euclide).
                    e_ticket_in = e_ticket_shift;
                    
                    rng_en      = 1'b0;
                    
                    keys_valid  = 1'b0;
                    e_key       = 32'b0;
                    d_key       = 32'b0;
                    
                    t1_ticket_in = t2_ticket_shift;
                    //t2_ticket_in = t_value;
                    t2_ticket_in = t1_ticket_shift - product;
                end
            endcase
        end
        else begin  //Se invece la pipeline di EuclidDivider non è ancora piena
            dividend    = phi;
            if (rng_e >= phi)     //ma rng_e è più grande di phi
                divisor = 32'b1;  //allora scarta il dato al prossimo giro;
            else                  //se invece rng_e è minore di phi
                divisor = rng_e;  //fallo entrare
            e_ticket_in = rng_e;
            
            rng_en      = en;     //e abilita l'LFSR (se E_KeyGenerator è abilitato).
            
            keys_valid  = 1'b0;
            e_key       = 32'b0;
            d_key       = 32'b0;
            
            t1_ticket_in = 33'b0;
            t2_ticket_in = 33'd1;
        end
    end //always
    
endmodule
