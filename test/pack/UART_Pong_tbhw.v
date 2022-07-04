`timescale 1ns / 100ps

module UART_Pong_tbhw (
    input wire clk,
    input wire rx,
    output wire tx
    );
    
    wire rx_readable;
    wire [7:0] received_byte;
    wire UNCONNECTED; //tx_busy
    
    reg [7:0] data = 8'b0;
    reg [2:0] count = 3'b0;
    reg rx_used_tick;
    reg tx_start;
    
    always @(posedge clk) begin
        rx_used_tick <= 1'b0;
        tx_start <= 1'b0;
        if (rx_readable) begin
            data <= received_byte;
            rx_used_tick <= 1'b1;
            tx_start <= 1'b1;
        end
    end
    
    UART_Pong DUT (
        .clk          (clk),
        .rst          (1'b0),
        
        .rx_stream    (rx),   //Stream seriali da collegare ai pin UART
        .tx_stream    (tx),
        
        .rx_used_tick (rx_used_tick),
        .rx_readable  (rx_readable),
        .rx_data      (received_byte),
        
        .tx_start     (tx_start),     //Pin di trasmissione dati
        .tx_data      (data),
        .tx_busy      (UNCONNECTED)
    );

endmodule
