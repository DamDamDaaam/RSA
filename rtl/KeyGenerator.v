`timescale 1ns / 100ps

//Modulo che genera le tre chiavi n_key, e_key e d_key
//mantenendole valide per un ciclo di clock; è responsabilità del
//KeyManager registrare le chiavi nel momento in cui vengono generate

module KeyGenerator (
    input wire clk,
    input wire rst,
    input wire en,     //alto quando mode=01 (Key generation), attiva LFSR
    input wire start,
    
    output wire [31:0] n_key,
    output wire [31:0] e_key,
    output wire [31:0] d_key,
    
    output wire n_key_valid, //tick da 1 clk che indicano la validità delle chiavi.
    output wire e_key_valid, //gli ultimi due salgono sempre insieme, e sono separati solo per
    output wire d_key_valid, //compatibilità con un vecchio design
    
    output reg busy         //Unico registro controllato direttamente dal modulo
    );
    
    wire e_key_valid_gen;
    wire d_key_valid_gen;
    
    assign e_key_valid = e_key_valid_gen & busy; //Salva solo la prima coppia e_key d_key
    assign d_key_valid = d_key_valid_gen & busy;
    
    //Manda alto busy quando si preme start, lo manda basso quando l'ultima chiave è generata
    always @(posedge clk) begin
        if (rst | d_key_valid)
            busy <= 1'b0;
        else if (start)
            busy <= 1'b1;
    end
    
    /////////////////////////////////////////
    // LFSR PSEUDO-RANDOM NUMBER GENERATOR // (Fonte di casualità: istante pressione start)
    /////////////////////////////////////////
    
    wire rng_en;
    wire nphi_require_rng;
    wire ed_require_rng;
    wire [31:0] rng_out;
    
    assign rng_en = (en & (~busy)) | (nphi_require_rng | ed_require_rng);
    
    LFSR32 rng_lfsr (
        .clk          (clk),
        .rst          (rst),
        .en           (rng_en),
        
        .rng_out      (rng_out)
    );
    
    ////////////////////
    // KEY GENERATORS //
    ////////////////////
    
    wire [31:0] phi;
    wire phi_valid;
    
    NnPhi_KeyGenerator n_phi_keygen (
        .clk         (clk),
        .rst         (rst),
        .start       (start),
        .random      (rng_out),
        
        .n_key       (n_key),
        .phi         (phi),
        .n_key_valid (n_key_valid),
        .phi_valid   (phi_valid),
        
        .rng_en      (nphi_require_rng)
    );
    
    EnD_KeyGenerator e_d_keygen (
        .clk         (clk),
        .rst         (rst | ~busy),
        .en          (phi_valid),
        .phi         (phi),
        .rng_e       (rng_out),
        
        .e_key_valid (e_key_valid_gen),
        .e_key       (e_key),
        .d_key_valid (d_key_valid_gen),
        .d_key       (d_key),
        
        .rng_en      (ed_require_rng)
    );
    
endmodule
