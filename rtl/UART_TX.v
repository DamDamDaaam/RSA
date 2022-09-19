`timescale 1ns / 100ps

//Macchina a stati finiti che gestisce la trasmissione di byte tramite UART.
//(Per il design è stato seguito l'esempio del Pong)

module UART_TX (
    input wire clk,
    input wire rst,
    input wire baud_tick,
    input wire tx_start,
    input wire [7:0] data_in,
    output reg tx_done_tick,
    output wire tx
    );
    
    //Definizione degli stati
    parameter [1:0] IDLE  = 2'b00;
    parameter [1:0] START = 2'b01; //Genera lo start bit
    parameter [1:0] WRITE = 2'b10; //Trasmette i bit di dati
    parameter [1:0] STOP  = 2'b11; //Genera lo stop bit
    
    //Definizione delle variabili
    reg [3:0] baud_count;
    reg [3:0] next_baud_count;
    
    reg [2:0] data_count;
    reg [2:0] next_data_count;
    
    reg [7:0] data;
    reg [7:0] next_data;
    
    reg tx_reg;
    reg next_tx_reg;
    
    assign tx = tx_reg;
    
    ////////////////////////////////////
    // SEQUENTIAL PART OF UART TX FSM //
    ////////////////////////////////////
    
    reg [1:0] state;
    reg [1:0] next_state;
    
    always @(posedge clk) begin
        if (rst) begin
            baud_count <= 4'b0;
            data_count <= 3'b0;
            data       <= 8'b0;
            tx_reg     <= 1'b1;
            
            state <= IDLE;
        end
        else begin
            baud_count <= next_baud_count;
            data_count <= next_data_count;
            data       <= next_data;
            tx_reg     <= next_tx_reg;
            
            state <= next_state;
        end
    end
    
    ///////////////////////////////////////
    // COMBINATIONAL PART OF UART TX FSM //
    ///////////////////////////////////////
    
    always @(*) begin
        next_state = state;
        tx_done_tick = 1'b0;
        next_baud_count = baud_count;
        next_data_count = data_count;
        next_data = data;
        next_tx_reg = tx_reg;
        
        case (state)
            IDLE: begin
                next_tx_reg = 1'b1;         //In IDLE il canale si mantiene alto.
                if (tx_start) begin         //Se si avvia una trasmissione
                    next_baud_count = 4'b0;
                    next_data = data_in;    //carica il byte nel buffer interno
                    
                    next_state = START;     //e passa a START.
                end
            end
            
            START: begin
                next_tx_reg = 1'b0;                 //Lo start bit è basso.
                if (baud_tick) begin
                    if (baud_count == 4'd15) begin  //Dopo il periodo corrispondente al baud rate
                        next_baud_count = 4'b0;
                        next_data_count = 3'b0;
                    
                        next_state = WRITE;         //passa in WRITE.
                    end
                    else
                        next_baud_count = baud_count + 4'b1;
                end
            end
            
            WRITE: begin
                next_tx_reg = data[0];              //Trasmette i bit di data uno alla volta.
                if (baud_tick) begin
                    if (baud_count == 4'd15) begin  //Dopo il tempo di un baud
                        next_baud_count = 4'b0;
                        next_data = data >> 1;      //shifta data per estrarre il prossimo bit.
                        if (data_count == 3'd7)     //Dopo aver inviato l'ottavo bit
                            next_state = STOP;      //passa a STOP.
                        else
                            next_data_count = data_count + 3'b1;
                    end
                    else
                        next_baud_count = baud_count + 4'b1;
                end
            end
            
            STOP: begin
                next_tx_reg = 1'b1;                 //Lo stop bit è alto.
                if (baud_tick) begin
                    if (baud_count == 4'd15) begin  //Dopo il tempo di un baud
                        tx_done_tick = 1'b1;        //comunica l'avvenuta trasmissione
                        
                        next_state = IDLE;          //e termina l'operazione.
                    end
                    else
                        next_baud_count = baud_count + 4'b1;
                end
            end
            
        endcase
    end
    
endmodule
