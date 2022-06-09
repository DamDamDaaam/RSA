`timescale 1ns / 100ps

module E_KeyGenerator(
    input wire clk,
    input wire rst,
    input wire en,            //Collegato al valid di phi
    input wire [31:0] seed,
    input wire [31:0] phi,
    output reg valid,
    output reg [31:0] e_key
    );
    
    wire [31:0] rng_e;
    
    reg  [31:0] e_ticket_in;  //Entra nel divider e quindi ha il pedice in
    
    wire [63:0] tickets_out;        //Dati passati attraverso i tuser di EuclidDivider
    wire [31:0] e_ticket_out;       //Valore iniziale del dividendo (potenziale e_key)
    wire [31:0] divisor_ticket;     //Valore del divisore necessario durante lo swap
    
    assign e_ticket_out = tickets_out[63:32];
    assign divisor_ticket = tickets_out[31:0];
    
    wire [63:0] data_out; //uscita di EuclidDivider
    wire [31:0] remainder;
  //wire [31:0] quotient;  
    
    assign remainder = data_out[31:0];
  //assign quotient  = data_out[63:32];
    
    wire steady_state;    //tvalid dell'output di EuclidDivider
    reg [31:0] dividend;
    reg [31:0] divisor;
    reg rng_en;
    
    assign div_tvalid = en & (~valid);  //TODO Aggiungere un ready dall'LFSR
    
    /////////////////////////////
    // DIVIDER Radix-2 IP CORE //  (latenza 35 clk, throughput 1 clk/div)
    /////////////////////////////
    
    EuclidDivider ekg_divider (
      .aclk    (clk ),
      .aresetn (~rst),
      
      .s_axis_divisor_tvalid  (div_tvalid  ),
      .s_axis_divisor_tuser   (divisor     ),
      .s_axis_divisor_tdata   (divisor     ),
      
      .s_axis_dividend_tvalid (div_tvalid  ),
      .s_axis_dividend_tuser  (e_ticket_in ),
      .s_axis_dividend_tdata  (dividend    ),
      
      .m_axis_dout_tvalid     (steady_state),
      .m_axis_dout_tuser      (tickets_out ),
      .m_axis_dout_tdata      (data_out    )
    );
    
    ///////////////////////////////////////
    // Register for final result storage //
    ///////////////////////////////////////
    
    /*reg key_found;                   //Questi registri potrebbero non essere necessari se
    reg [31:0] verified_e_key;         //si decide di scaricare a KeyGenerator la
                                       //responsabilità di spedire la chiave appena verificata
    initial begin                      //al KeyManager
        valid <= 1'b0;
        e_key <= 32'b0;
    end
    
    always @(posedge clk) begin
        if (key_found) begin
            valid <= 1'b1;
            e_key <= verified_e_key;
        end
    end*/
    
    //////////////////////////////////////////
    // COMBINATIONAL EUCLID ALGORITHM LOGIC //
    //////////////////////////////////////////
    
    always @(*) begin
        if (rst) begin
            dividend    = 32'b0;
            divisor     = 32'b0;
            e_ticket_in = 32'b0;
                
            rng_en      = 1'b0;
                
            valid       = 1'b0;
            e_key       = 32'b0;
        end
        else if (steady_state) begin   //Se la pipeline del divider è piena:
            case (remainder)
                32'b0: begin              //Se trovato GCD =/= 1
                    dividend    = phi;
                    divisor     = rng_e;  //fai entrare un nuovo numero casuale
                    e_ticket_in = rng_e;
                    
                    rng_en      = 1'b1;   //e abilita l'LFSR.
                    
                    valid       = 1'b0;
                    e_key       = 32'b0;
                end
                
                32'b1: begin                     //Se trovato GCD == 1
                    dividend    = 32'hCACABEEE;         
                    divisor     = 32'hCACABEEE;         //non ha importanza cosa mando al divider
                    e_ticket_in = 32'hCACABEEE;         //perchè tanto la procedura è finita;
                    
                    rng_en      = 1'b0;
                    
                    valid       = 1'b1;          //segnala che la chiave è valida
                    e_key       = e_ticket_out;  //e mandala in output al modulo.
                end
                
                default: begin                      //Se GCD non trovato
                    dividend    = divisor_ticket;   //sostituisci dividendo con divisore
                    divisor     = remainder;        //e divisore con resto (Euclide).
                    e_ticket_in = e_ticket_out;
                    
                    rng_en      = 1'b0;
                    
                    valid       = 1'b0;
                    e_key       = 32'b0;
                end
            endcase
        end
        else begin  //Se invece la pipeline di EuclidDivider non è ancora piena
            dividend    = phi;
            divisor     = rng_e;  //fai entrare un nuovo numero casuale
            e_ticket_in = rng_e;
            
            rng_en      = en;     //e abilita l'LFSR (se E_KeyGenerator è abilitato).
            
            valid       = 1'b0;
            e_key       = 32'b0;
        end
    end //always
 
endmodule