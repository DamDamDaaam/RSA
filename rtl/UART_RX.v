`timescale 1ns / 100ps

//Macchina a stati finiti che gestisce la ricezione di byte tramite UART.
//(Per il design è stato seguito l'esempio del Pong)

module UART_RX (
    input wire clk,
    input wire rst,
    input wire baud_tick,
    input wire rx,
    output reg rx_done_tick,
    output wire [7:0] data_out
    );
    
    //Definizione degli stati
    parameter [1:0] IDLE  = 2'b00;
    parameter [1:0] START = 2'b01; //attende fino a metà dello start bit e passa alla lettura
    parameter [1:0] READ  = 2'b10; //legge i bit in arrivo e li shifta in data
    parameter [1:0] STOP  = 2'b11; //attende fino a metà dello stop bit e torna in IDLE
    
    //Definizione delle variabili
    reg [3:0] baud_count;
    reg [3:0] next_baud_count;
    
    reg [2:0] data_count;
    reg [2:0] next_data_count;
    
    reg [7:0] data;
    reg [7:0] next_data;
    
    assign data_out = data;
    
    ////////////////////////////////////
    // SEQUENTIAL PART OF UART RX FSM //
    ////////////////////////////////////
    
    reg [1:0] state;
    reg [1:0] next_state;
    
    always @(posedge clk) begin
        if (rst) begin
            baud_count <= 4'b0;
            data_count <= 3'b0;
            data       <= 8'b0;
            
            state <= IDLE;
        end
        else begin
            baud_count <= next_baud_count;
            data_count <= next_data_count;
            data       <= next_data;
            
            state <= next_state;
        end
    end
    
    //////////////////////////////////////
    // COMBINATIONAL PART OF UART RX FSM//
    //////////////////////////////////////
    
    always @(*) begin
        next_state = state;            //Se non specificato diversamente mantieni tutto uguale
        rx_done_tick = 1'b0;           //e rx_done a 0
        next_baud_count = baud_count;
        next_data_count = data_count;
        next_data = data;
        
        case (state)
            IDLE: begin
                if (~rx) begin              //Se si riceve lo start bit (che è 0)
                    next_baud_count = 4'b0;
                    
                    next_state = START;     //avvia l'operazione di lettura.
                end
            end
            
            START: begin
                if (baud_tick) begin
                    if (baud_count == 4'd7) begin   //A metà dello start bit
                        next_baud_count = 4'b0;
                        next_data_count = 3'b0;
                    
                        next_state = READ;          //passa in modalità di lettura.
                    end
                    else
                        next_baud_count = baud_count + 4'b1;
                end
            end
            
            READ: begin
                if (baud_tick) begin
                    if (baud_count == 4'd15) begin //Da qui baud_count è 15 a metà del bit.
                        next_baud_count = 4'b0;
                        next_data = {rx, data[7:1]}; //Shifta il bit corrente in data.
                        if (data_count == 3'd7)      //Dopo aver shiftato l'ottavo bit
                            next_state = STOP;       //passa a STOP.
                        else
                            next_data_count = data_count + 3'b1;
                    end
                    else
                        next_baud_count = baud_count + 4'b1;
                end
            end
            
            STOP: begin
                if (baud_tick) begin
                    if (baud_count == 4'd15) begin  //A metà dello stop bit
                        rx_done_tick = 1'b1;        //comunica l'avvenuta ricezione
                        
                        next_state = IDLE;          //e termina l'operazione.
                    end
                    else
                        next_baud_count = baud_count + 4'b1;
                end
            end
            
        endcase
    end
    
endmodule
