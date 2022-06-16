`timescale 1ns / 100ps

//Ricevitore UART con baud rate 19.2 kHz

module UART_Receiver_Bit (
    input wire clk,
    input wire rst,
    input wire baud_tick,   //Tick ricevuto a frequenza 307200 Hz (16*baud_rate)
    input wire rx,          //Input seriale.
    output reg bit_ready,   //Tick inviato ogni volta che un nuovo bit è disponibile.
    output reg data_out     //Valore del bit leggibile
    );
    
    reg  bit_ready_baud;    //Tick lungo inviato quando un bit è pronto
    reg  [2:0] data_count;  //Registro contenente il numero di bit ricevuti
    wire rx_done;           //Segnale alto quando l'ultimo bit viene ricevuto
    
    assign rx_done = (data_count == 3'd7);
    assign data_out = rx;
    
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
    
    ////////////////////////////////////////////
    // BAUD TICK TO SINGLE CLK TICK CONVERTER //
    ////////////////////////////////////////////
    
    reg [1:0] q;
    
    always @(posedge clk) begin
        q[0] <= bit_ready_baud;
        q[1] <= q[0] & (~bit_ready_baud);
    end
    
    assign bit_ready = q[1];
    
    //////////////////////////
    // SEQUENTIAL FSM LOGIC //
    //////////////////////////
    
    always @(posedge clk) begin
        if (rst) begin
            data_count <= 3'b0;
            state <= IDLE;
        end
        else begin
            if (bit_ready)                         //Se un bit è pronto alla lettura
                data_count  <= data_count + 3'b1;  //aggiungi 1 al numero di bit ricevuti
            state <= next_state;
        end
    end
    
    /////////////////////////////
    // COMBINATORIAL FSM LOGIC //
    /////////////////////////////
    
    always @(*) begin
        case (state)
            IDLE: begin
                bit_ready_baud = 1'b0;
                counter_rst    = 1'b1;
                if (rx == 1'b1)
                    next_state = IDLE;
                else
                    next_state = START;
            end
            
            START: begin
                bit_ready_baud = 1'b0;
                if (baud_count == 4'd8) begin
                    counter_rst = 1'b1;
                    next_state = READ;
                end
                else begin
                    counter_rst = 1'b0;
                    next_state = START;
                end
            end
            
            READ: begin
                counter_rst = 1'b0;
                if (baud_count == 4'd15) begin
                    bit_ready_baud = 1'b1;
                    if (rx_done)
                        next_state = STOP;
                    else
                        next_state = READ;
                end
                else begin
                    bit_ready_baud = 1'b0;
                    next_state = READ;
                end
            end
            
            STOP: begin
                bit_ready_baud = 1'b0;
                counter_rst    = 1'b0;
                if (baud_count == 4'd14)
                    next_state = IDLE;
                else
                    next_state = STOP;
            end
        endcase
    end
    
endmodule
