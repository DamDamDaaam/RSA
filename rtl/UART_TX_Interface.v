`timescale 1ns / 100ps

//Interfaccia diretta, priva di buffer, che si occupa solo di settare la flag tx_busy.
//I dati non passano dall'interfaccia, bensì raggiungono direttamente il transmitter.

module UART_TX_Interface (
    input wire clk,
    input wire rst,
    input wire clear_flag,    //Viene da tx_done_tick di UART_TX e comunica l'avvenuto invio
    input wire set_flag,      //Viene da Crypter (attraverso UART) e richiede l'invio di un byte
    output wire flag
    );
    
    reg flag_reg;
    reg next_flag;

    assign flag = flag_reg;   
    
    always @(posedge clk) begin
        if (rst)
            flag_reg <= 1'b0;
        else
            flag_reg <= next_flag;
    end
    
    always @(*) begin
        next_flag = flag_reg;
        if (set_flag)
            next_flag = 1'b1;
        else if (clear_flag)
            next_flag = 1'b0;
    end
    
endmodule
