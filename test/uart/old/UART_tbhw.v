`timescale 1ns / 100ps

module UART_tbhw (
    input wire clk,
    input wire rx,
    output wire tx
    );
    
    wire rx_ready;
    wire received_bit;
    wire UNCONNECTED; //tx_ready
    
    reg [7:0] data = 8'b0;
    reg [2:0] count = 3'b0;
    reg tx_start;
    
    always @(posedge clk) begin
        if (rx_ready) begin
            data <= {received_bit, data} >> 1;
            count <= count + 3'b1;
            if (count == 3'd0)
                tx_start <= 1'b1;
            else
                tx_start <= 1'b0;
        end
        else
            tx_start <= 1'b0;
    end
    
    UART DUT (
        .clk         (clk),
        .rst         (1'b0),
        
        .rx_stream   (rx),   //Stream seriali da collegare ai pin UART
        .tx_stream   (tx),
        
        .rx_bit      (received_bit),      //Pin di ricezione dati
        .rx_ready    (rx_ready), 
        
        .tx_start    (tx_start),     //Pin di trasmissione dati
        .tx_data     (data),
        .tx_ready    (UNCONNECTED)
    );

endmodule
