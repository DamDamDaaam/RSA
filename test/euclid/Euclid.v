`timescale 1ns / 100ps

//MACCHINA A STATI FINITI PER LA VERIFICA DEL VINCOLO
//GCD(phi, rng_e) == 1

//TODO migliorare efficienza: al momento un'operazione prende centinaia di colpi di clk

module Euclid(
        input wire clk,
        input wire rst,
        input wire start,        //Vuole un impulso della durata di uno o pochi cicli di clock
        input wire [31:0] phi,
        input wire [31:0] rng_e,
        output reg should_redo,  //Produce un impulso di un ciclo di clock se GCD =/= 1
        output reg valid,
        output wire [31:0] e_key //La chiave verificata se valid è alto, altrimenti inaffidabile
    );
    
    reg div_tvalid;
    reg  [31:0] divisor_register  = 32'b0;  //registro di lavoro small
    reg  [31:0] dividend_register = 32'b0;  //registro di lavoro big
    wire [63:0] division_result;
    wire remainder;
    wire UNCONNECTED, UNCONNECTED_2;        //tready del divisore non necessari poichè la
                                            //macchina attende il termine della divisione
    
    assign e_key = rng_e;
    assign remainder = division_result[31:0 ];
    
    /////////////////////////////
    // DEFINIZIONE DEGLI STATI //
    /////////////////////////////
    
    parameter integer IDLE   = 3'h0; //Attende l'impulso di start
    parameter integer LOAD   = 3'h1; //Carica phi e rng_e nei registri di lavoro big e small
    parameter integer DIVIDE = 3'h2; //Avvia la divisione di big per small
    parameter integer CHECK  = 3'h3; //Se la divisione è completata controlla il GCD
    parameter integer SWAP   = 3'h4; //Mette small in big e il resto della divisione in small
    parameter integer DONE   = 3'h5; //Operazione completata: rimane fisso 
    
    ///////////////////////
    // PARTE SEQUENZIALE //
    ///////////////////////
    
    reg [2:0] state      = IDLE;
    reg [2:0] next_state = IDLE; 
        
    always @(posedge clk) begin
        if (state == LOAD) begin
            dividend_register <= phi;
            divisor_register  <= rng_e;
        end
        else if (state == SWAP) begin
            dividend_register <= divisor_register;
            divisor_register  <= remainder;
        end
        if (rst) state <= IDLE;
        else state <= next_state;
    end
    
    ////////////////////////
    // PARTE COMBINATORIA //
    ////////////////////////
    
    always @(*) begin
        case (state)
        
            IDLE:
            begin
                should_redo = 1'b0;
                valid       = 1'b0;
                div_tvalid  = 1'b0;
                
                if (start) next_state = LOAD;  //Se RNG_E ti manda una chiave caricala
                else next_state = IDLE;        //altrimenti attendi.
            end
            
            LOAD:
            begin
                should_redo = 1'b0;
                valid       = 1'b0;
                div_tvalid  = 1'b0;
                
                next_state = DIVIDE;  //Al prossimo ciclo gli operandi saranno pronti: dividi.
            end
            
            DIVIDE:
            begin
                should_redo = 1'b0;
                valid       = 1'b0;
                div_tvalid  = 1'b1;  //Avvia la divisione
                
                next_state = CHECK; //poi controllane lo stato e/o i risultati.
            end
            
            CHECK:
            begin
                if (division_done) begin  //Se la divisione è fatta
                    div_tvalid = 1'b0;    //disabilita il divisore; poi:
                
                    if (remainder == 1'b1) begin        //Se GCD == 1
                        should_redo = 1'b0;
                        valid       = 1'b1;            //allora la chiave è valida
                        next_state = DONE;             //quindi termina.
                    end
                    else if (remainder == 1'b0) begin  //Se GCD =/= 1
                        valid       = 1'b0;
                        should_redo = 1'b1;            //allora chiedi un'altra chiave
                        next_state = IDLE;             //e attendi risposta.
                    end
                    else begin                         //Se l'algoritmo non è ancora terminato
                        should_redo = 1'b0;
                        valid       = 1'b0;
                        next_state = SWAP;             //allora passa al prossimo step.
                    end
                end
                else begin              //Se la divisione è ancora in corso
                    div_tvalid  = 1'b1; //mantieni attivo il divisore
                    should_redo = 1'b0;
                    valid       = 1'b0;
                    next_state = CHECK; //e attendi.
                end
            end
            
            SWAP:
            begin
                should_redo = 1'b0;
                valid       = 1'b0;
                div_tvalid  = 1'b0;
                
                next_state = DIVIDE;  //Avvia la divisione dei nuovi operandi
            end
            
            DONE:
            begin
                should_redo = 1'b0;
                valid       = 1'b1;        //Mantieni valid fisso alto
                div_tvalid  = 1'b0;
                
                next_state = DONE;   //fino al prossimo reset.
            end
            
            default:                 //Necessario per evitare latch
            begin                    //ma se tutto va bene irraggiungibile
                should_redo = 1'b0;
                valid       = 1'b0;
                div_tvalid  = 1'b0;
                
                next_state = IDLE;
            end
            
        endcase
    end

    ////////////////////////////////
    // DIVISORE Radix-2 (IP CORE) //  (latenza 37 clk, throughput 2 clk/div)
    ////////////////////////////////
    
    EuclidDivider(
        .aclk    (clk ),
        .aresetn (~rst),
        
        .s_axis_divisor_tvalid  (div_tvalid      ),
        .s_axis_divisor_tready  (UNCONNECTED),
        .s_axis_divisor_tdata   (divisor_register),
        
        .s_axis_dividend_tvalid (div_tvalid       ),
        .s_axis_dividend_tready (UNCONNECTED_2),
        .s_axis_dividend_tdata  (dividend_register),
        
        .m_axis_dout_tvalid     (division_done  ),
        .m_axis_dout_tdata      (division_result)
    );
    
endmodule
