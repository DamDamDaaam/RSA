`timescale 1ns / 100ps

//Modulo che genera le tre chiavi n_key, e_key e d_key sequenzialmente
//mantenendole valide per un ciclo di clock. è responsabilità del
//KeyManager registrare le chiavi nel momento in cui vengono generate

module KeyGenerator (
    input wire clk,
    input wire rst,
    input wire start,
    
    output reg [31:0] n_key,
    output reg [31:0] e_key,
    output reg [31:0] d_key,
    
    output reg n_key_valid,
    output reg e_key_valid,
    output reg d_key_valid,
    output reg busy
    );
    
    ///////////////////////////////////////
    // RNG (XADC Wizard and 32-bit LFSR) //
    ///////////////////////////////////////
    
    wire [31:0] seed;
    
    //TODO questo modulo deve ancora essere scritto
    SeedGenerator seeder (
        .seed_out(seed)
    );
    
    LFSR32 rng (
        .clk     (clk),
        .rst     (rst),
        .seed    (seed),
        .rng_out ()
    );
    
    //////////////////////////
    // GENERATORI DI CHIAVI //
    //////////////////////////
    
    wire phi_valid;
    wire [31:0] phi;
    
    //TODO aggiungere gli altri generatori di chiavi
    
    E_KeyGenerator e_keygen (
        .clk   (clk),
        .rst   (rst),
        .en    (phi_valid),
        
        .seed  (seed),
        .phi   (phi),
        
        .valid (e_key_valid),
        .e_key (e_key)
    );
    
endmodule
