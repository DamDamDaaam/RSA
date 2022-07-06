`timescale 1ns / 100ps

module UART_RX_Pong (
    input wire clk,
    input wire rst,
    input wire baud_tick,
    input wire rx,
    output reg rx_done_tick,
    output wire [7:0] data_out
    );
    
    //Definizione degli stati
    parameter [1:0] IDLE  = 2'b00;
    parameter [1:0] START = 2'b01;
    parameter [1:0] READ  = 2'b10;
    parameter [1:0] STOP  = 2'b11;
    
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
                if (~rx) begin
                    next_baud_count = 4'b0;
                    
                    next_state = START;
                end
            end
            
            START: begin
                if (baud_tick) begin
                    if (baud_count == 4'd7) begin
                        next_baud_count = 4'b0;
                        next_data_count = 3'b0;
                    
                        next_state = READ;
                    end
                    else
                        next_baud_count = baud_count + 4'b1;
                end
            end
            
            READ: begin
                if (baud_tick) begin
                    if (baud_count == 4'd15) begin
                        next_baud_count = 4'b0;
                        next_data = {rx, data[7:1]};
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
                if (baud_tick) begin
                    if (baud_count == 4'd15) begin
                        rx_done_tick = 1'b1;
                        
                        next_state = IDLE;
                    end
                    else
                        next_baud_count = baud_count + 4'b1;
                end
            end
            
        endcase
    end
    
endmodule