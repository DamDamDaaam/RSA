`timescale 1ns / 100ps

//Modulo che genera le chiavi
//n = p * q
//phi = (p - 1) * (q - 1)
//con p e q numeri primi casuali di 16 bit o meno

//la chiave n è valida solo per un ciclo di clock, durante il quale KeyManager deve salvarla,
//mentre phi viene salvato in un registro interno a questo modulo, e rimane fisso fino a rst
//o successiva generazione

module NnPhi_KeyGenerator(
    input wire clk,
    input wire rst,
    input wire start,
    input wire [31:0] random, //output di LFSR32; alcuni fili non sono connessi perchè in
    output reg rng_en,        //questo modulo non servono numeri casuali di 32 bit
    output reg [31:0] n_key,
    output reg [31:0] phi,
    output reg n_key_valid,
    output reg phi_valid      //collegato all'en di EnD_KeyGenerator
    );
    
    //banchi di flip flop gestiti dal modulo
    reg [15:0] p;
    reg [15:0] q;
  //reg [31:0] phi;
  //reg phi_valid;
    reg waitCounter;
    
    ///////////////////////////////
    // 16-BIT MULTIPLIER IP CORE // (Latenza 4 clk)
    ///////////////////////////////
    
    reg  [15:0] mult1;
    reg  [15:0] mult2;
    wire [31:0] product;
    
    Multiplier_16bit n_phi_mult (
        .CLK(clk),
        .A(mult1),
        .B(mult2),
        .P(product)
    );
    
    //////////////////////////////
    // 16-BIT PRIME NUMBERS ROM //
    //////////////////////////////
    
    reg  [12:0] random_addr;  //slice diverso di random a seconda di GEN_P o GEN_Q
    wire [15:0] random_prime;
    
    Primes16BitROM primes_rom (
        .clk(clk),
        .addr(random_addr),
        .data(random_prime)
    );
    
    ////////////////////////
    // KEY GENERATION FSM //
    ////////////////////////
    
    parameter [2:0] IDLE     = 3'h0;
    parameter [2:0] GEN_P    = 3'h1; //Generazione numero primo p
    parameter [2:0] GEN_Q    = 3'h2; //Generazione numero primo q
    parameter [2:0] MULT_N   = 3'h3; //Avvio moltiplicazione n = p * q
    parameter [2:0] MULT_PHI = 3'h4; //Avvio moltiplicazione phi = (p - 1) * (q - 1)
    parameter [2:0] WAIT     = 3'h5; //Attesa del termine della prima moltiplicazione
    parameter [2:0] SEND_N   = 3'h6; //Invio della chiave n a KeyManager
    parameter [2:0] SAVE_PHI = 3'h7; //Salvataggio di phi nel registro
    
    reg [2:0] state;
    reg [2:0] next_state;
    
    always @(posedge clk) begin
        if (rst) begin
            p <= 16'b0;
            q <= 16'b0;
            phi <= 32'b0;
            phi_valid <= 1'b0;
            waitCounter <= 1'b0;
            state <= IDLE;
        end
        else begin
            if (state == GEN_P)
                p <= random_prime;
            else if (state == GEN_Q)
                q <= random_prime;
            else if (state == WAIT)
                waitCounter <= ~waitCounter;
            else if (state == SAVE_PHI) begin
                phi <= product;
                phi_valid <= 1'b1;
            end
            state <= next_state;
        end
    end
    
    always @(*) begin
        case (state)
            IDLE: begin
                mult1 = 16'b0;
                mult2 = 16'b0;
                n_key = 32'b0;
                n_key_valid = 1'b0;
                random_addr = random[12:0];
                if (start) begin         //Se ricevi il segnale di start
                    rng_en = 1'b1;       //avvia il generatore di numeri casuali
                    next_state = GEN_P;  //e entra nella procedura
                end
                else begin
                    rng_en = 1'b0;
                    next_state = IDLE;   //altrimenti attendi.
                end
            end
            
            GEN_P: begin
                rng_en = 1'b1;              //Genera numeri casuali
                random_addr = random[12:0]; //prendendoli dalla parte destra di random.
                mult1 = 16'b0;
                mult2 = 16'b0;
                n_key = 32'b0;
                n_key_valid = 1'b0;
                next_state = GEN_Q;
            end
            
            GEN_Q: begin
                rng_en = 1'b1;               //Genera numeri casuali
                random_addr = random[28:16]; //prendendoli dalla parte sinistra di random.
                mult1 = 16'b0;
                mult2 = 16'b0;
                n_key = 32'b0;
                n_key_valid = 1'b0;
                if (random_prime == p)   //Se i numeri primi sono uguali
                    next_state = GEN_Q;  //generane uno nuovo
                else
                    next_state = MULT_N; //altrimenti procedi.
            end
            
            MULT_N: begin
                rng_en = 1'b0;
                mult1 = p;           //Moltiplica p
                mult2 = q;           //con q
                n_key = 32'b0;
                n_key_valid = 1'b0;
                random_addr = random[12:0];
                next_state = MULT_PHI;
            end
            
            MULT_PHI: begin
                rng_en = 1'b0;
                mult1 = p - 16'b1;   //Moltiplica (p - 1)
                mult2 = q - 16'b1;   //con (q - 1)
                n_key = 32'b0;
                n_key_valid = 1'b0;
                random_addr = random[12:0];
                next_state = WAIT;
            end
            
            WAIT: begin
                rng_en = 1'b0;
                mult1 = 16'b0;
                mult2 = 16'b0;
                n_key = 32'b0;
                n_key_valid = 1'b0;
                random_addr = random[12:0];
                if (waitCounter == 1'b1)  //Se sono già due clk che aspetti
                    next_state = SEND_N;  //procedi a inviare N
                else
                    next_state = WAIT;    //altrimenti attendi.
            end
            
            SEND_N: begin
                rng_en = 1'b0;
                mult1 = 16'b0;
                mult2 = 16'b0;
                n_key = product;       //Invia la chiave N al KeyManager
                n_key_valid = 1'b1;    //e notifica che è valida
                random_addr = random[12:0];
                next_state = SAVE_PHI;
            end
            
            SAVE_PHI: begin      //phi viene salvato nel blocco sequenziale
                rng_en = 1'b0;
                mult1 = 16'b0;
                mult2 = 16'b0;
                n_key = 32'b0;
                n_key_valid = 1'b0;
                random_addr = random[12:0];
                next_state = IDLE;
            end
            
        endcase
    end
    
endmodule
