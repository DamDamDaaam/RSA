`timescale 1ns / 100ps

module UART (
    input wire clk,
    input wire rst,
    
    input wire  rx_stream,   //Stream seriali da collegare ai pin UART
    output wire tx_stream,
    
    output wire rx_bit,      //Pin di ricezione dati
    output wire rx_ready, 
    
    input wire tx_start,     //Pin di trasmissione dati
    input wire [7:0] tx_data,
    output wire tx_ready
    
    );
    
    //////////////////////////////////////////
    // BAUD RATE TICK GENERATOR (307.2 kHz) //
    //////////////////////////////////////////
    
    wire baud_tick;
    
    BaudTicker
    #(.BAUD_RATE(19200))    //Baud rate per la sintesi.
  //#(.BAUD_RATE(625000))   //Baud rate per la simulazione.
    uart_baud_gen (         //ATTENZIONE: baud_rate 19.2 kHz internamente
        .clk  (clk),        //approssimato a 19.17 kHz se la frequenza di
        .rst  (rst),        //clk è 100 MHz.
        .tick (baud_tick)
    );
    
    /////////////////////////////////////
    // RECEIVER AND TRASMITTER MODULES //
    /////////////////////////////////////
    
    UART_Receiver_Bit uart_rx (
        .clk        (clk),
        .rst        (rst),
        .baud_tick  (baud_tick),
        
        .rx         (rx_stream),
        
        .bit_ready  (rx_ready),
        .data_out   (rx_bit)
    );
    
    UART_Transmitter uart_tx (
        .clk        (clk),
        .rst        (rst),
        .baud_tick  (baud_tick),
        
        .start      (tx_start),
        .data       (tx_data),
        
        .tx         (tx_stream),
        .ready      (tx_ready)
    );
    
endmodule
