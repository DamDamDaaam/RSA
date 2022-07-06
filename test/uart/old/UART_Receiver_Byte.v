`timescale 1ns / 100ps

//Ricevitore UART con baud rate 19.2 kHz

module UART_Receiver_Byte (
    input wire clk,
    input wire rst,
    input wire baud_tick,   //Tick ricevuto a frequenza 307200 Hz (16*baud_rate)
    input wire rx,          //Input seriale.
    output reg data_valid,  //Tick inviato a fine lettura.
    output reg [7:0] data   //Shift register contenente i dati letti.
    );
    
    reg  bit_ready;               //Tick inviato quando si è centrati su un bit ricevuto
    reg  [2:0] data_count;        //Registro contenente il numero di bit ricevuti
    wire [8:0] uart_rx_shiftreg;  //Variabile di comodità per shiftare facilmente
    wire rx_done;                 //Segnale alto quando l'ultimo bit viene ricevuto
    
    assign uart_rx_shiftreg = {rx, data};
    assign rx_done = (data_count == 3'd7);
    
    ///////////////////////
    // STATES DEFINITION //
    ///////////////////////
    
    parameter [1:0] IDLE  = 2'b00;
    parameter [1:0] START = 2'b01;
    parameter [1:0] READ  = 2'b11;
    parameter [1:0] STOP  = 2'b10;
    
    reg [1:0] state;
    reg [1:0] next_state;
    
    ///////////////////////
    // 307.2 kHz COUNTER //
    ///////////////////////
    
    reg  counter_rst;
    wire counter_en;
    wire [3:0] baud_count;
    
    assign counter_en = (state != IDLE) & baud_tick;
    
    BaudCounter uart_rx_counter (
        .clk   (clk),
        .rst   (counter_rst),
        .en    (counter_en),
        .count (baud_count)
    );
    
    //////////////////////////
    // SEQUENTIAL FSM LOGIC //
    //////////////////////////
    
    always @(posedge clk) begin
        if (rst) begin
            data_count <= 3'b0;
            data       <= 8'b0;
            state <= IDLE;
        end
        else begin
            if (bit_ready) begin                   //Se un bit è pronto alla lettura
                data_count  <= data_count + 3'b1;  //aggiungi 1 al numero di bit ricevuti
                data <= uart_rx_shiftreg >> 1;     //e shifta il bit nella variabile data 
            end
            state <= next_state;
        end
    end
    
    /////////////////////////////
    // COMBINATORIAL FSM LOGIC //
    /////////////////////////////
    
    always @(*) begin
        case (state)
            IDLE: begin
                data_valid  = 1'b0;
                bit_ready   = 1'b0;
                counter_rst = 1'b1;
                if (rx == 1'b1)
                    next_state = IDLE;
                else
                    next_state = START;
            end
            
            START: begin
                data_valid  = 1'b0;
                bit_ready   = 1'b0;
                if (baud_count == 4'd7) begin
                    counter_rst = 1'b1;
                    next_state = READ;
                end
                else begin
                    counter_rst = 1'b0;
                    next_state = START;
                end
            end
            
            READ: begin
                data_valid = 1'b0;
                counter_rst = 1'b0;
                if (baud_count == 4'd15) begin
                    bit_ready = 1'b1;
                    if (rx_done)
                        next_state = STOP;
                    else
                        next_state = READ;
                end
                else begin
                    bit_ready = 1'b0;
                    next_state = READ;
                end
            end
            
            STOP: begin
                data_valid = 1'b1;
                bit_ready = 1'b0;
                counter_rst = 1'b0;
                if (baud_count == 4'd15)
                    next_state = IDLE;
                else
                    next_state = STOP;
            end
        endcase
    end
    
endmodule
