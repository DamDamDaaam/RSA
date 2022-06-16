`timescale 1ns / 100ps

module UART_Transmitter (
    input wire clk,
    input wire rst,
    input wire baud_tick,
    input wire start,
    input wire [7:0] data,
    output reg tx,
    output reg ready
    );
    
    wire bit_ready_baud;   //Tick lungo quando un bit è pronto al trasferimento
    reg bit_ready;         //Tick breve (1 clk) con lo stesso significato
    reg [2:0] data_count;  //Registro contenente il numero di bit inviati
    reg [7:0] data_buf;    //Shift register riempito con data allo start (PISO)
    reg tx_done;           //Alto quando tutti i bit sono stati inviati
    reg long_start;        //Segnale di start lungo fino al baud tick successivo
    
    assign tx_done = (data_count == 3'd7);
    
    ///////////////////////
    // STATES DEFINITION //
    ///////////////////////
    
    parameter [1:0] IDLE  = 2'b00;
    parameter [1:0] START = 2'b01;
    parameter [1:0] SEND  = 2'b11;
    parameter [1:0] STOP  = 2'b10;
    
    reg [1:0] state;
    reg [1:0] next_state;
    
    ///////////////////////
    // 307.2 kHz COUNTER //
    ///////////////////////
    
    wire counter_en;
    wire [3:0] baud_count;
    
    assign counter_en = (state != IDLE) & baud_tick;
    
    BaudCounter uart_tx_counter (
        .clk   (clk),
        .rst   (rst),
        .en    (counter_en),
        .count (baud_count)
    );
    
    assign bit_ready_baud = (baud_count == 4'd15);
    
    ////////////////////////////////////////////
    // BAUD TICK TO SINGLE CLK TICK CONVERTER // (Debouncino)
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
            long_start <= 1'b0;
            state <= IDLE;
        end
        else begin
            if ((state == IDLE) & start)
                long_start <= 1'b1;
            else if (state == START) begin
                long_start <= 1'b0;
                data_buf <= data;
            end
            else if ((state == SEND) && bit_ready) begin
                data_count  <= data_count + 3'b1;
                data_buf <= data_buf >> 1;
            end
            if (bit_ready | (long_start & baud_tick))
                state <= next_state;
        end
    end
    
    /////////////////////////////
    // COMBINATORIAL FSM LOGIC //
    /////////////////////////////
    
    always @(*) begin
        case (state)
            IDLE: begin
                tx    = 1'b1;
                ready = 1'b1;
                if (long_start)
                    next_state = START;
                else
                    next_state = IDLE;
            end
            
            START: begin
                tx    = 1'b0;
                ready = 1'b0;
                next_state = SEND;
            end
            
            SEND: begin
                tx    = data_buf[0];
                ready = 1'b0;
                if (tx_done)
                    next_state = STOP;
                else
                    next_state = SEND;
            end
            
            STOP: begin
                tx    = 1'b1;
                ready = 1'b0;
                next_state = IDLE;
            end
        endcase
    end

endmodule
