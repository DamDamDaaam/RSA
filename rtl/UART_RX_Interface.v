`timescale 1ns / 100ps

//Interfaccia dotata di un buffer da un byte dedicato alla verifica della condizione di EOT.
//Gestisce anche la flag rx_readable, che indica che ci sono dati ricevuti non letti

module UART_RX_Interface (
    input wire clk,
    input wire rst,
    input wire clear_flag,    //Viene da Crypter (attraverso UART) e comunica l'avvenuta lettura
    input wire set_flag,      //Viene da rx_done_tick di UART_RX e comunica l'arrivo di un byte
    input wire [7:0] data_in,
    output wire flag,
    output wire eot,
    output wire [7:0] data_out
    );

    reg [7:0] data_buf = 8'b0;
    reg [7:0] next_data_buf;
    
    reg flag_reg = 1'b0;
    reg next_flag_reg;
    
    reg eot_reg = 1'b0;
    reg next_eot_reg;
    
    assign flag = flag_reg;   
    assign eot = eot_reg;
    assign data_out = data_buf;
    
    always @(posedge clk) begin
        if (rst) begin
            data_buf <= 8'b0;
            flag_reg <= 1'b0;
            eot_reg <= 1'b0;
        end
        else begin
            data_buf <= next_data_buf;
            flag_reg <= next_flag_reg;
            eot_reg <= next_eot_reg;
        end
    end
    
    always @(*) begin
        next_data_buf = data_buf;
        next_flag_reg = flag_reg;
        next_eot_reg = eot_reg;
        
        if (set_flag) begin            //se è stato ricevuto un byte
            next_data_buf = data_in;   //bufferizzalo in data_buf
            next_flag_reg = 1'b1;      //e alza rx_readable.
            if (data_in == 8'd4)       //se il byte è EOT
                next_eot_reg = 1'b1;   //alza anche la flag di EOT.
        end
        else if (clear_flag) begin     //se è stato letto il byte nel buffer
            next_flag_reg = 1'b0;      //abbassa rx_readable
            next_eot_reg = 1'b0;       //e la flag di EOT
        end
    end
    
endmodule
