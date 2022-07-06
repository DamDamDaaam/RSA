`timescale 1ns / 100ps

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
    parameter [1:0] START = 2'b01;
    parameter [1:0] WRITE = 2'b10;
    parameter [1:0] STOP  = 2'b11;
    
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
    
    //////////////////////////////////////
    // COMBINATIONAL PART OF UART TX FSM//
    //////////////////////////////////////
    
    always @(*) begin
        next_state = state;            //Se non specificato diversamente mantieni tutto uguale
        tx_done_tick = 1'b0;           //e tx_done_tick a zero
        next_baud_count = baud_count;
        next_data_count = data_count;
        next_data = data;
        next_tx_reg = tx_reg;
        
        case (state)
            IDLE: begin
                next_tx_reg = 1'b1;
                if (tx_start) begin
                    next_baud_count = 4'b0;
                    next_data = data_in;
                    
                    next_state = START;
                end
            end
            
            START: begin
                next_tx_reg = 1'b0;
                if (baud_tick) begin
                    if (baud_count == 4'd15) begin
                        next_baud_count = 4'b0;
                        next_data_count = 3'b0;
                    
                        next_state = WRITE;
                    end
                    else
                        next_baud_count = baud_count + 4'b1;
                end
            end
            
            WRITE: begin
                next_tx_reg = data[0];
                if (baud_tick) begin
                    if (baud_count == 4'd15) begin
                        next_baud_count = 4'b0;
                        next_data = data >> 1;
                        if (data_count == 3'd7)
                            next_state = STOP;
                        else
                            next_data_count = data_count + 3'b1;
                    end
                    else
                        next_baud_count = baud_count + 4'b1;
                end
            end
            
            STOP: begin
                next_tx_reg = 1'b1;
                if (baud_tick) begin
                    if (baud_count == 4'd15) begin
                        tx_done_tick = 1'b1;
                        
                        next_state = IDLE;
                    end
                    else
                        next_baud_count = baud_count + 4'b1;
                end
            end
            
        endcase
    end
    
endmodule
