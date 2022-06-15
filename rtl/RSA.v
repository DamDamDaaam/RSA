
// Top level module - interfaccia utente


`timescale 1ns / 100ps

module RSA(
    
    input wire clk,
    input wire [1:0] mode_select,       // SW[3:2]
    //input wire out_en,                  // SW[1]   è stato usato come test
    input wire var_sel,                 // SW[0]
    
    input wire del,                     // BTN[3]
    input wire start,                   // BTN[2]
    input wire select,                  // BTN[1]
    input wire add,                     // BTN[0]
    
    output wire [7:0] display,
    output wire [11:0] anode
    
    );
    
    wire [31:0] n_key;
    wire [31:0] e_key;
    wire [31:0] d_key;
    
    wire typing;
    wire [3:0] digit;
    wire [31:0] writing;
    
    reg [3:0] show_mode;                        // carattere di mode
    reg [31:0] show_key;                        // chiave da stampare
    
    KeyManager chiavi(
    
    .clk            (         clk ),
    .mode           ( mode_select ),
/////////////////   TEST    ////////////////
//    .key_valid_test (      out_en ),
/////////////////   TEST    ////////////////
    .select_key     (     var_sel ),
    
    .del_but        (         del ),
    .start_but      (       start ),
    .move_left_but  (      select ),
    .add_one_but    (         add ),
    
    .typing         (      typing ),
    .digit          (       digit ),
    .writing        (     writing ),
    
    .n_key          (       n_key ),
    .e_key          (       e_key ),
    .d_key          (       d_key )
    
    );
    
    // RESET GLOBALE
//    wire rst;
//    assign rst = (mode_select == 2'b00);
    
    reg working;
    
    always @(*) begin
        case(mode_select[1:0])
            2'b00 : begin                       // Spento   ->  RESET GLOBALE (attivo alto)
                show_mode = 4'ha;               // "-."
                show_key = 32'h0;               // "0000000000"
                working = 1'b1;
            end
            
            2'b01 :                             // Generazione chiavi
                if(start) begin                 // DA SOSTITUIRE:   start -> busy di KeyGenerator
                    show_mode = 4'h5;           // "S."
                    show_key = 32'h0;           // "0000000000"
                    working = 1'b1;
                end
                else begin
                    if(var_sel==1'b0) begin     // mostra chiave n
                        show_mode = 4'hb;       // "n."
                        show_key = n_key;
                        working = 1'b0;
                    end
                    else begin
                        if(select) begin        // mostra chiave d
                            show_mode = 4'hd;   // "d."
                            show_key = d_key;
                            working = 1'b0;
                        end
                        else begin              // mostra chiave e
                            show_mode = 4'he;   // "E."
                            show_key = e_key;
                            working = 1'b0;
                        end
                    end
                    
                    // if(start) -> avvia keygen
                end
                
            2'b11 :                             // Crittaggio
                if(start) begin                 // DA SOSTITUIRE start -> busy di Encrypter
                    show_mode = 4'hc;           // "C."
                    show_key = 32'h0;           // "0000000000"
                    working = 1'b1;
                    
                    // en UART in crypt mode
                end
                else begin
                    if(var_sel==1'b0) begin     // mostra/modifica chiave n
                        show_mode = 4'hb;       // "n."
                        working = 1'b0;
                        if(typing)
                            show_key = writing;
                        else
                            show_key = n_key;
                    end
                    else begin                  // mostra/modifica chiave e
                        show_mode = 4'he;       // "E."
                        working = 1'b0;
                        if(typing)
                            show_key = writing;
                        else
                            show_key = e_key;
                    end
                end
                
            2'b10 :                             // Decrittaggio
                if(start) begin                 // DA SOSTITUIRE start -> busy di Decrypter
                    show_mode = 4'hf;           // "U."
                    show_key = 32'h0;           // "0000000000"
                    working = 1'b1;
                end
                else begin
                    if(var_sel==1'b0) begin     // mostra/modifica chiave n
                        show_mode = 4'hb;       // "n."
                        working = 1'b0;
                        if(typing)
                            show_key = writing;
                        else
                            show_key = n_key;
                    end
                    else begin                  // mostra/modifica chiave e
                        show_mode = 4'hd;       // "d."
                        working = 1'b0;
                        if(typing)
                            show_key = writing;
                        else
                            show_key = d_key;
                    end
                end
        endcase
    end
    
    
    wire [39:0] BCD_val;
    
    ConverterBCD_Comb bin2bcd (
        .bin(show_key),
        .bcd(BCD_val)
    );
    
    SevenSegment_12_Digits schermo (
    
        .clk      (               clk ),
//        .en       ( out_en & ~working ),
        .en       (          ~working ),
        .mode     (         show_mode ),      // input della mode da stampare a video
        .BCD      (           BCD_val ),      // input del numero da stampare a video
        
        .typing   (            typing ),
        .digit    (             digit ),
        
        .segA     (        display[7] ),
        .segB     (        display[6] ),
        .segC     (        display[5] ),
        .segD     (        display[4] ),
        .segE     (        display[3] ),
        .segF     (        display[2] ),
        .segG     (        display[1] ),
        .DP       (        display[0] ),
        .anode    (             anode )
    
    );
    
endmodule
