
// Top level module - interfaccia utente

`timescale 1ns / 100ps

module RSA (

    input wire clk_100,
    input wire [1:0] mode_select,       // SW[3:2]
    input wire var_sel,                 // SW[0]
    
    input wire del_but,                 // BTN[3]
    input wire start_but,               // BTN[2]
    input wire select_but,              // BTN[1]
    input wire add_but,                 // BTN[0]
    
    input wire rx_stream,               // uart_txd_in
    output wire tx_stream,              // uart_rxd_out
    
    output wire [7:0] display,
    output wire [11:0] anode
    );
    
    //////////////////////////////////////
    // PLL PER LA GENERAZIONE DEL CLOCK //
    //////////////////////////////////////
    
    parameter real CLOCK_FREQUENCY = 100000000.0;
    
    wire clk;
    wire locked;
    
    PLL pll (
        .clk_in     (clk_100),
        .pll_clk    (clk),
        .pll_locked (locked)
    );
    
    ///////////////////
    // RESET GLOBALE //
    ///////////////////
    
    wire rst;
    
    assign rst = (!mode_select) | (~locked);
    
    /////////////////////////////
    // DEBOUNCER PER I BOTTONI //
    /////////////////////////////
    
    wire del;
    wire start;
    wire select;
    wire add;
    
    wire [3:0] buttons;
    wire [3:0] debounced;
    
    genvar k;
    
    assign buttons = {del_but, start_but, select_but, add_but};
    assign {del, start, select, add} = debounced;
    
    generate
        for (k = 0; k < 4; k = k + 1) begin
            Debouncer deb (
                .clk    (clk),
                .button (buttons[k]),
                .pulse  (debounced[k])
            );
        end
    endgenerate
    
    /////////////////////////////////////
    // MODULO DI GESTIONE DELLE CHIAVI //
    /////////////////////////////////////
    
    wire [31:0] n_key;
    wire [31:0] e_key;
    wire [31:0] d_key;
    
    wire typing;
    wire [3:0] digit;
    wire [31:0] writing;
    
    reg [3:0] show_mode;                        // carattere di mode
    reg [31:0] show_key;                        // chiave da stampare
    
    wire kg_busy;
    
    KeyManager chiavi(
        .clk            (         clk ),
        .rst            (         rst ),
        .mode           ( mode_select ),
        .select_key     (     var_sel ),
        
        .del            (         del ),
        .start          (       start ),
        .move_left      (      select ),
        .add_one        (         add ),
        
        .typing         (      typing ),
        .digit          (       digit ),
        .writing        (     writing ),
        
        .n_key          (       n_key ),
        .e_key          (       e_key ),
        .d_key          (       d_key ),
        
        .kg_busy        (     kg_busy )
    );
    
    //////////////////////////////////////////////////////
    // INTERFACCIA UART PER RICEVERE E TRASMETTERE DATI //
    //////////////////////////////////////////////////////
    
    wire rx_used_tick;
    wire rx_readable;
    wire eot;
    wire [7:0] rx_data;
    
    wire tx_start;
    wire [7:0] tx_data;
    wire tx_busy;
    wire tx_done_tick;
    
    UART #(.CLOCK_FREQUENCY_HZ(CLOCK_FREQUENCY)) uart (
        .clk           (clk),
        .rst           (rst | ~mode_select[1]),
        
        .rx_stream     (rx_stream),      //Canali di comunicazione con l'esterno
        .tx_stream     (tx_stream),
        
        .rx_used_tick  (rx_used_tick),   //Pin relativi alla ricezione
        .rx_readable   (rx_readable),
        .eot           (eot),
        .rx_data       (rx_data),
        
        .tx_start      (tx_start),       //Pin relativi alla trasmissione
        .tx_data       (tx_data),
        .tx_busy       (tx_busy),
        .tx_done_tick  (tx_done_tick)
    );
    
    ///////////////////////////////////////////////
    // MODULO PER CRIPTARE E DECRIPTARE MESSAGGI //
    ///////////////////////////////////////////////
    
    wire crypter_busy;
    
    Crypter crypter (
        .clk           (clk),
        .rst           (rst | ~mode_select[1]),
        .mode          (mode_select[0]),
        
        .start         (start),
        
        .n_key         (n_key),
        .e_key         (e_key),
        .d_key         (d_key),

        .eot_in        (eot),        //Collegamenti con ricevitore UART
        .ready_in      (rx_readable),
        .data_in       (rx_data),
        .clear_rx_flag (rx_used_tick),
        
        .tx_done_tick  (tx_done_tick),  //Collegamenti con trasmettitore UART
        .start_out     (tx_start),
        .data_out      (tx_data),
        
        .busy          (crypter_busy)
    );
    
    ////////////////////////
    // INTERFACCIA UTENTE //
    ////////////////////////
    
    reg working;
    
    always @(*) begin
        case(mode_select[1:0])
            2'b00 : begin                       // Spento   ->  RESET GLOBALE (attivo alto)
                show_mode = 4'ha;               // "-."
                show_key = 32'h0;               // "0000000000"
                working = 1'b1;
            end
            
            2'b01 :                             // Generazione chiavi
                if(start_but | kg_busy) begin
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
                        if(select_but) begin    // mostra chiave d
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
                end
                
            2'b11 :                             // Crittaggio
                if(crypter_busy) begin
                    show_mode = 4'hc;           // "C."
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
                        show_mode = 4'he;       // "E."
                        working = 1'b0;
                        if(typing)
                            show_key = writing;
                        else
                            show_key = e_key;
                    end
                end
                
            2'b10 :                             // Decrittaggio
                if(crypter_busy) begin
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
    
    /////////////////////////////////////////////////////
    // MODULI DI CONTROLLO PER IL DISPLAY A 7 SEGMENTI //
    /////////////////////////////////////////////////////
    
    wire [39:0] BCD_val;
    
    ConverterBCD_Comb bin2bcd (
        .bin(show_key),
        .bcd(BCD_val)
    );
    
    SevenSegment_12_Digits schermo (
    
        .clk      (               clk ),
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
