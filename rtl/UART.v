`timescale 1ns / 100ps

//Percorso dei dati:
//Mondo esterno ----> Receiver ----> RX Interface ----> Crypter
//Crypter ----> Transmitter ----> Mondo esterno

module UART #(parameter real CLOCK_FREQUENCY_HZ)
    (
    input wire clk,
    input wire rst,
    
    input  wire rx_stream,     //Canali di comunicazione con l'esterno. Collegare in XDC
    output wire tx_stream,
    
    input wire rx_used_tick,   //Pin relativi alla ricezione
    output wire rx_readable,
    output wire eot,
    output wire [7:0] rx_data,
    
    input wire tx_start,       //Pin relativi alla trasmissione
    input wire [7:0] tx_data,
    output wire tx_busy,
    output wire tx_done_tick
    );
    
    //Collegamenti interni
    wire baud_tick;
    wire rx_done_tick;
    //wire tx_done_tick; //SCOMMENTARE SE SERVE TOGLIERLO DALLA PORT LIST
    wire [7:0] rx_data_unbuffered;
    
    
    BaudTicker
    #(.BAUD_RATE(19200), .CLOCK_FREQ(CLOCK_FREQUENCY_HZ))
  //#(.BAUD_RATE(625000), .CLOCK_FREQ(CLOCK_FREQUENCY_HZ))     //Baud rate di simulazione
    baud_ticker (
        .clk  (clk),
        .rst  (rst),
        .tick (baud_tick)
    );
    
    UART_RX uart_receiver (
        .clk          (clk),
        .rst          (rst),
        .baud_tick    (baud_tick),
        .rx           (rx_stream),
        
        .rx_done_tick (rx_done_tick),
        .data_out     (rx_data_unbuffered)
    );
    
    UART_TX uart_transmitter (
        .clk          (clk),
        .rst          (rst),
        .baud_tick    (baud_tick),
        .tx_start     (tx_start),
        .data_in      (tx_data),
        
        .tx           (tx_stream),
        .tx_done_tick (tx_done_tick)
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
    
    UART_TX_Interface uart_tx_interface (
        .clk         (clk),
        .rst         (rst),
        .clear_flag  (tx_done_tick),
        .set_flag    (tx_start),
        
        .flag        (tx_busy)
    );
    
endmodule
