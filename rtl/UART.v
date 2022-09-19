`timescale 1ns / 100ps

//Modulo che gestisce il protocollo di comunicazione UART per la comunicazione di messaggi
//e cifrati tra il PC e l'FPGA.
//(Per il design è stato seguito l'esempio del Pong)

//Trasmissione e ricezione possono avvenire in parallelo, essendo su due canali diversi. Questo
//design fa uso di questa funzionalità nel Decrypter, mentre l'Encrypter fa solo una delle due
//operazioni alla volta per questione di semplicità.

//In ricezione i dati inviati dal PC raggiungono il modulo UART_RX, vengono bufferizzati in
//UART_RX_Interface e da lì vengono letti dal Crypter.

//In trasmissione i dati prodotti dal Crypter non attraversano il modulo UART_TX_Interface, che
//gestisce solo la flag tx_busy, e vanno direttamente da UART_TX al PC.

module UART #(parameter real CLOCK_FREQUENCY_HZ)
    (
    input wire clk,
    input wire rst,
    
    input  wire rx_stream,     //Canali di comunicazione con l'esterno
    output wire tx_stream,     //
    
    input wire rx_used_tick,   //Pin relativi alla ricezione
    output wire rx_readable,   //
    output wire eot,           //
    output wire [7:0] rx_data, //
    
    input wire tx_start,       //Pin relativi alla trasmissione
    input wire [7:0] tx_data,  //
    output wire tx_busy,       //
    output wire tx_done_tick   //
    );
    
    //Collegamenti interni
    wire baud_tick;
    wire rx_done_tick;
    wire [7:0] rx_data_unbuffered;
    
    //////////////////////////////////////////////////////
    // GENERATORE DI TICK ALLA FREQUENZA 16 * baud_rate //
    //////////////////////////////////////////////////////
    
    BaudTicker
    #(.BAUD_RATE(19200), .CLOCK_FREQ(CLOCK_FREQUENCY_HZ))
  //#(.BAUD_RATE(625000), .CLOCK_FREQ(CLOCK_FREQUENCY_HZ))     //Baud rate di simulazione
    baud_ticker (
        .clk  (clk),
        .rst  (rst),
        .tick (baud_tick)
    );
    
    /////////////////////////////
    // MODULI PER LA RICEZIONE //
    /////////////////////////////
    
    UART_RX uart_receiver (
        .clk          (clk),
        .rst          (rst),
        .baud_tick    (baud_tick),
        .rx           (rx_stream),
        
        .rx_done_tick (rx_done_tick),
        .data_out     (rx_data_unbuffered)
    );
    
    UART_RX_Interface uart_rx_interface (
        .clk         (clk),
        .rst         (rst),
        .clear_flag  (rx_used_tick),
        .set_flag    (rx_done_tick),
        .data_in     (rx_data_unbuffered),
        
        .flag        (rx_readable),
        .eot         (eot),
        .data_out    (rx_data)
    );
    
    ////////////////////////////////
    // MODULI PER LA TRASMISSIONE //
    ////////////////////////////////
    
    UART_TX uart_transmitter (
        .clk          (clk),
        .rst          (rst),
        .baud_tick    (baud_tick),
        .tx_start     (tx_start),
        .data_in      (tx_data),
        
        .tx           (tx_stream),
        .tx_done_tick (tx_done_tick)
    );
    
    UART_TX_Interface uart_tx_interface (
        .clk         (clk),
        .rst         (rst),
        .clear_flag  (tx_done_tick),
        .set_flag    (tx_start),
        
        .flag        (tx_busy)
    );
    
endmodule
