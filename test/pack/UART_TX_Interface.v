`timescale 1ns / 100ps

//Interfaccia diretta, priva di buffer, che si occupa solo di settare la flag tx_busy.
//I dati non passano dall'interfaccia, bensì raggiungono direttamente il transmitter.
//Se in futuro dovesse servire il buffer, è possibile usare direttamente UART_RX_Interface_Pong, scambiando solo i significati di set_flag e clear_flag quando la si collega.

module UART_TX_Interface (
    input wire clk,
    input wire rst,
    input wire clear_flag,    //Viene da tx_done_tick di UART_TX e dice "Ho inviato i dati"
    input wire set_flag,      //Viene da Crypter (attraverso UART) e dice "Devi inviare i dati"
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

//SCOMMENTARE SE SERVISSE RITORNARE AL MODELLO IN CUI L'INTERFACCIA SPACCHETTA 32 BIT DI DATI
//TRA L'ALTRO POTREBBE ESSERE FARLOCCA/DA FINIRE

/*`timescale 1ns / 100ps

//Interfaccia dotata di un buffer da un byte da dedicare alla verifica della condizione di EOT

module UART_RX_Interface_Pong (
    input wire clk,
    input wire rst,
    input wire clear_flag,    //Viene da tx_done_tick di UART_TX e dice "Ho inviato i dati"
    input wire set_flag,      //Viene da Crypter (attraverso UART) e dice "Devi inviare i dati"
    input wire [31:0] data_in,
    output wire flag,
    output wire [7:0] data_out
    );

    reg [31:0] data_buf;
    reg [31:0] next_data_buf;
    
    reg [1:0] byte_count;
    reg [1:0] next_byte_count;
    
    reg flag_reg;
    reg next_flag_reg;

    assign flag = flag_reg;   
    assign data_out = data_buf; 
    
    always @(posedge clk) begin
        if (rst) begin
            data_buf <= 32'b0;
            flag_reg <= 1'b0;
        end
        else begin
            data_buf <= next_data_buf;
            flag_reg <= next_flag_reg;
        end
    end
    
    always @(*) begin
        next_data_buf = data_buf;
        next_flag_reg = flag_reg;
        if (set_flag) begin
            next_data_buf = data_in;
            next_flag_reg = 1'b1;
        end
        else if (clear_flag) begin
            if (byte_count == 2'd3) begin
                next_flag = 1'b0;
            end
            next_flag = 1'b1;
            next_byte = data_buf[31:24];
            next_byte_count = byte_count + 2'b1;
            next_data_buf = data_buf << 8;
        end
        
    end
    
endmodule*/
