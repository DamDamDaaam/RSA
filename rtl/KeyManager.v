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
    input wire rst,
    input wire [1:0] mode,          // SW[3:2]
    input wire select_key,          // SW[0]
    
    input wire del,                 // BTN[3] ( del    )    //Bottoni già debounced
    input wire start,               // BTN[2] ( start  )
    input wire move_left,           // BTN[1] ( select )
    input wire add_one,             // BTN[0] ( add    )
    
    output  reg typing,             // flag per comunicare che si sta editando una chiave
    output wire [3:0] digit,        // cifra che si sta editando
    output wire [31:0] writing,     // valore che si sta editando
    
    output reg [31:0] n_key,        //Banchi di flip flop che tengono memoria delle chiavi
    output reg [31:0] e_key,
    output reg [31:0] d_key,
    
    output wire kg_busy             // informa che KeyGenerator sta calcolando chiavi
    );
    
    reg  kg_start;                  // dà al KeyGenerator il via per generare chiavi
    reg  kg_rst;                    // rst di KeyGenerator
    reg  kg_en;                     // enable di KeyGenerator
    
    wire [31:0] n_key_gen;          // n_key generata dal KeyGenerator
    wire [31:0] e_key_gen;          // e_key generata dal KeyGenerator
    wire [31:0] d_key_gen;          // d_key generata dal KeyGenerator
    
    wire n_key_valid;               // flag che fa salvare il valore di n_key generato dal KeyGenerator
    wire e_key_valid;               // flag che fa salvare il valore di e_key generato dal KeyGenerator
    wire d_key_valid;               // flag che fa salvare il valore di d_key generato dal KeyGenerator
    
    KeyGenerator keygen (
        .clk         (clk),
        .rst         (rst | kg_rst),
        .en          (kg_en),
        .start       (kg_start),
        
        .n_key       (n_key_gen),
        .e_key       (e_key_gen),
        .d_key       (d_key_gen),
        
        .n_key_valid (n_key_valid),
        .e_key_valid (e_key_valid),
        .d_key_valid (d_key_valid),
        .busy        (kg_busy)
    );
    
    reg [3:0] position;
    reg [3:0] value;
    reg [31:0] tot;
    
    assign digit = position;
    assign writing = tot;
    
    always @(posedge clk) begin
        if (rst) begin
            typing <= 'b0;                     // Reset globale (mode = 0 oppure ~locked)
                
            n_key <= 'b0;
            e_key <= 'b0;
            d_key <= 'b0;
            
            kg_start <= 1'b0;
            kg_rst <= 1'b1;
            kg_en  <= 1'b0;
        end
        else case(mode[1:0])
            2'b00 : begin                       // Mode su "reset" ma rst spento.
                typing <= 'b0;                  // Se tutto va bene condizione mai verificata
                
                n_key <= 'b0;
                e_key <= 'b0;
                d_key <= 'b0;
                
                kg_start <= 1'b0;
                kg_rst <= 1'b1;
                kg_en  <= 1'b0;
            end
            
            2'b01 : begin                       // Generazione chiavi
                typing <= 1'b0;
                
                kg_en  <= 1'b1;
                
                if(n_key_valid)
                    n_key <= n_key_gen;
                if(e_key_valid)
                    e_key <= e_key_gen;
                if(d_key_valid)
                    d_key <= d_key_gen;
                                
                if(del) begin                    // se si preme delete resetta il KeyGenerator
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
                kg_en  <= 1'b0;
                
                if(select_key == 1'b0) begin    // mostra/modifica chiave n
                    if(del) begin                                       // premere delete...
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
                    if(del) begin                                       // premere delete...
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
                kg_en  <= 1'b0;
                
                if(select_key == 1'b0) begin    // mostra/modifica chiave n
                    if(del) begin                                       // premere delete...
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
                    if(del) begin                                       // premere delete...
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
