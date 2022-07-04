`timescale 1ns / 100ps

//Percorso dei dati:
//Mondo esterno ----> Receiver ----> RX Interface ----> Crypter
//Crypter ----> Transmitter ----> Mondo esterno

module UART_Pong (
    input wire clk,
    input wire rst,
    
    //Canali di comunicazione con l'esterno. Collegare in XDC
    input  wire rx_stream,
    output wire tx_stream,
    
    //Pin relativi alla ricezione
    input wire rx_used_tick,
    output wire rx_readable,
    output wire [7:0] rx_data,
    
    //Pin relativi alla trasmissione
    input wire tx_start,
    input wire [7:0] tx_data,
    output wire tx_busy
    );
    
    //Collegamenti interni
    wire baud_tick;
    wire rx_done_tick;
    wire tx_done_tick;
    wire [7:0] rx_data_unbuffered;
    
    
    BaudTicker #(.BAUD_RATE(19200)) baud_ticker (
        .clk  (clk),
        .rst  (rst),
        .tick (baud_tick)
    );
    
    UART_RX_Pong uart_receiver (
        .clk          (clk),
        .rst          (rst),
        .baud_tick    (baud_tick),
        .rx           (rx_stream),
        
        .rx_done_tick (rx_done_tick),
        .data_out     (rx_data_unbuffered)
    );
    
    UART_TX_Pong uart_transmitter (
        .clk          (clk),
        .rst          (rst),
        .baud_tick    (baud_tick),
        .tx_start     (tx_start),
        .data_in      (tx_data),
        
        .tx           (tx_stream),
        .tx_done_tick (tx_done_tick)
    );
    
    UART_RX_Interface_Pong uart_rx_interface (
        .clk         (clk),
        .rst         (rst),
        .clear_flag  (rx_used_tick),
        .set_flag    (rx_done_tick),
        .data_in     (rx_data_unbuffered),
        
        .flag        (rx_readable),
        .data_out    (rx_data)
    );
    
    UART_TX_Interface_Pong uart_tx_interface (
        .clk         (clk),
        .rst         (rst),
        .clear_flag  (tx_done_tick),
        .set_flag    (tx_start),
        
        .flag        (tx_busy)
    );
    
endmodule
