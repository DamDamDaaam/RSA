//
// Modulo che si occupa della gestione delle chiavi
// Prevede che il KeyGenerator sia dotato di:
//    input:
//        - start       avvia la generazione
//        - rst         resetta tutto il modulo
//    output:
//        - busy            0 -> non operativo      1 -> calcolo delle chiavi in corso
//        - n_key_gen       valore della chiave da immagazzinare in n_key
//        - n_key_valid     tick che dice quando questo valore è valido
//        - e_key_gen       valore della chiave da immagazzinare in e_key
//        - e_key_valid     tick che dice quando questo valore è valido
//        - d_key_gen       valore della chiave da immagazzinare in d_key
//        - d_key_valid     tick che dice quando questo valore è valido
//

`timescale 1ns / 100ps

module KeyManager(
    
    input wire clk,
    input wire [1:0] mode,          // SW[3:2]
/////////////////   TEST    ////////////////
    input wire key_valid_test,      // SW[1]
/////////////////   TEST    ////////////////
    input wire select_key,          // SW[0]
    
    input wire del_but,             // BTN[3] ( del    )
    input wire start,               // BTN[2] ( start  )
    input wire move_left_but,       // BTN[1] ( select )
    input wire add_one_but,         // BTN[0] ( add    )
    
    output  reg typing,             // flag per comunicare che si sta editando una chiave
    output wire [3:0] digit,        // cifra che si sta editando
    output wire [31:0] writing,     // valore che si sta editando
    
    output reg [31:0] n_key,
    output reg [31:0] e_key,
    output reg [31:0] d_key
    
    );
    
    wire delete;
    wire move_left;
    wire add_one;
    
    Debouncer delete_deb (
        
        .clk    (           clk ),
        .button (       del_but ),
        .pulse  (        delete )
        
    );

    Debouncer move_left_deb (
        
        .clk    (           clk ),
        .button ( move_left_but ),
        .pulse  (     move_left )
        
    );
    
    Debouncer add_one_deb (
        
        .clk    (           clk ),
        .button (   add_one_but ),
        .pulse  (       add_one )
        
    );
    
    reg  kg_start;                  // dà al KeyGenerator il via per generare chiavi
    reg  kg_rst;                    // rst di KeyGenerator
    wire kg_busy;                   // informa che KeyGenerator sta calcolando chiavi
    
    wire [31:0] n_key_gen;          // n_key generata dal KeyGenerator
    wire [31:0] e_key_gen;          // e_key generata dal KeyGenerator
    wire [31:0] d_key_gen;          // d_key generata dal KeyGenerator
    
    wire n_key_valid;               // flag che fa salvare il valore di n_key generato dal KeyGenerator
    wire e_key_valid;               // flag che fa salvare il valore di e_key generato dal KeyGenerator
    wire d_key_valid;               // flag che fa salvare il valore di d_key generato dal KeyGenerator
    
/////////////////   TEST    ////////////////
    assign n_key_valid = key_valid_test;
    assign e_key_valid = key_valid_test;
    assign d_key_valid = key_valid_test;
    
    assign n_key_gen = 32'd666666666;
    assign e_key_gen = 32'd123456789;
    assign d_key_gen = 32'd987654321;
/////////////////   TEST    ////////////////
    
    reg [3:0] position;
    reg [3:0] value;
    reg [31:0] tot;
    
    assign digit = position;
    assign writing = tot;
    
    
    always @(posedge clk) begin
        case(mode[1:0])
            2'b00 : begin                       // Spento   ->  RESET GLOBALE
                typing <= 'b0;
                
                n_key <= 'b0;
                e_key <= 'b0;
                d_key <= 'b0;
                
                kg_start <= 1'b0;
                kg_rst <= 1'b1;
            end
            
            2'b01 : begin                       // Generazione chiavi
                typing <= 1'b0;
                
                if(n_key_valid)
                    n_key <= n_key_gen;
                if(e_key_valid)
                    e_key <= e_key_gen;
                if(d_key_valid)
                    d_key <= d_key_gen;
                                
                if(delete) begin                    // se si preme delete resetta il KeyGenerator
                    kg_rst <= 1'b1;
                    kg_start <= 1'b0;
                end
                else begin
                    kg_rst <= 1'b0;
                    
                    if(start && ~kg_busy)           // se si preme start e non sta già generando inizia la generazione di chiavi
                        kg_start <= 1'b1;
                    else
                        kg_start <= 1'b0;
                end
            end
            
            2'b11 : begin                       // Crittaggio
                kg_start <= 1'b0;
                kg_rst <= 1'b0;
                
                if(select_key == 1'b0) begin    // mostra/modifica chiave n
                    if(delete) begin                                    // premere delete...
                        if(typing == 1'b0)                              // ...mentre non si sta scrivendo...
                            typing <= 1'b1;                             // ...avvia la scrittura...
                        else begin                  // (se si sta scrivendo...
                            typing <= 1'b0;         // ...interrompe la scrittura...
                            n_key <= 'b0;           // ...e cancella la chiave)
                        end
                    end
                    else begin
                        if(move_left && (position == 4'd9)) begin       // ...che dando un move_left dopo l'ultima cifra...
                            typing <= 1'b0;                             // ...termina...
                            n_key <= tot;                               // ...salvando il valore di tot nella chiave
                        end
                    end
                end
                else begin                  // mostra/modifica chiave e
                    if(delete) begin                                    // premere delete...
                        if(typing == 1'b0)                              // ...mentre non si sta scrivendo...
                            typing <= 1'b1;                             // ...avvia la scrittura...
                        else begin                  // (se si sta scrivendo...
                            typing <= 1'b0;         // ...interrompe la scrittura...
                            e_key <= 'b0;           // ...e cancella la chiave)
                        end
                    end
                    else begin
                        if(move_left && (position == 4'd9)) begin       // ...che dando un move_left dopo l'ultima cifra...
                            typing <= 1'b0;                             // ...termina...
                            e_key <= tot;                               // ...salvando il valore di tot nella chiave
                        end
                    end
                end
            end
            
            2'b10 : begin                       // Decrittaggio
                kg_start <= 1'b0;
                kg_rst <= 1'b0;
                
                if(select_key == 1'b0) begin    // mostra/modifica chiave n
                    if(delete) begin                                    // premere delete...
                        if(typing == 1'b0)                              // ...mentre non si sta scrivendo...
                            typing <= 1'b1;                             // ...avvia la scrittura...
                        else begin                  // (se si sta scrivendo...
                            typing <= 1'b0;         // ...interrompe la scrittura...
                            n_key <= 'b0;           // ...e cancella la chiave)
                        end
                    end
                    else begin
                        if(move_left && (position == 4'd9)) begin       // ...che dando un move_left dopo l'ultima cifra...
                            typing <= 1'b0;                             // ...termina...
                            n_key <= tot;                               // ...salvando il valore di tot nella chiave
                        end
                    end
                end
                else begin                  // mostra/modifica chiave d
                    if(delete) begin                                    // premere delete...
                        if(typing == 1'b0)                              // ...mentre non si sta scrivendo...
                            typing <= 1'b1;                             // ...avvia la scrittura...
                        else begin                  // (se si sta scrivendo...
                            typing <= 1'b0;         // ...interrompe la scrittura...
                            d_key <= 'b0;           // ...e cancella la chiave)
                        end
                    end
                    else begin
                        if(move_left && (position == 4'd9)) begin       // ...che dando un move_left dopo l'ultima cifra...
                            typing <= 1'b0;                             // ...termina...
                            d_key <= tot;                               // ...salvando il valore di tot nella chiave
                        end
                    end
                end
            end
        endcase
    end
    
    ////////////////////////////////////////////////////
    // EDITOR DELLE CHIAVI (attivo quando typing = 1) //
    ////////////////////////////////////////////////////
    
    always @(posedge clk) begin
        if(typing) begin
            if(move_left) begin
                value <= 'b0;
//                if(position == 4'd9) begin
//                    position <= 4'd0;               // dare conferma del valore
//                    value <= 4'd0;
//                end
//                else
                position <= position + 4'd1;
            end
            if(add_one) begin
                case(position)
                    4'd0 :  begin
                        if(value == 4'd9) begin
                            value <= 'b0;
                            tot <= tot - 32'd9;
                        end
                        else begin
                            value <= value + 4'd1;
                            tot <= tot + 32'd1;
                        end
                    end
                    4'd1 :  begin
                        if(value == 4'd9) begin
                            value <= 'b0;
                            tot <= tot - 32'd90;
                        end
                        else begin
                            value <= value + 4'd1;
                            tot <= tot + 32'd10;
                        end
                    end
                    4'd2 :  begin
                        if(value == 4'd9) begin
                            value <= 'b0;
                            tot <= tot - 32'd900;
                        end
                        else begin
                            value <= value + 4'd1;
                            tot <= tot + 32'd100;
                        end
                    end
                    4'd3 :  begin
                        if(value == 4'd9) begin
                            value <= 'b0;
                            tot <= tot - 32'd9000;
                        end
                        else begin
                            value <= value + 4'd1;
                            tot <= tot + 32'd1000;
                        end
                    end
                    4'd4 :  begin
                        if(value == 4'd9) begin
                            value <= 'b0;
                            tot <= tot - 32'd90000;
                        end
                        else begin
                            value <= value + 4'd1;
                            tot <= tot + 32'd10000;
                        end
                    end
                    4'd5 :  begin
                        if(value == 4'd9) begin
                            value <= 'b0;
                            tot <= tot - 32'd900000;
                        end
                        else begin
                            value <= value + 4'd1;
                            tot <= tot + 32'd100000;
                        end
                    end
                    4'd6 :  begin
                        if(value == 4'd9) begin
                            value <= 'b0;
                            tot <= tot - 32'd9000000;
                        end
                        else begin
                            value <= value + 4'd1;
                            tot <= tot + 32'd1000000;
                        end
                    end
                    4'd7 :  begin
                        if(value == 4'd9) begin
                            value <= 'b0;
                            tot <= tot - 32'd90000000;
                        end
                        else begin
                            value <= value + 4'd1;
                            tot <= tot + 32'd10000000;
                        end
                    end
                    4'd8 :  begin
                        if(value == 4'd9) begin
                            value <= 'b0;
                            tot <= tot - 32'd900000000;
                        end
                        else begin
                            value <= value + 4'd1;
                            tot <= tot + 32'd100000000;
                        end
                    end
                    4'd9 :  begin
                        if(tot > 32'd3294967295) begin          // impedisce di raggiungere 4 per evitare overflow 
                            value <= 'b0;
                            tot <= tot - 32'd3000000000;
                        end
                        else begin
                            if(value == 4'd4) begin
                                value <= 'b0;
                                tot <= tot - 32'd4000000000;
                            end
                            else begin
                                value <= value + 4'd1;
                                tot <= tot + 32'd1000000000;
                            end
                        end
                    end
                endcase
            end
            
        end
        else begin
            position <= 'b0;
            value <= 'b0;
            tot <= 'b0;
        end
    end
    
    
endmodule
