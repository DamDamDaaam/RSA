`timescale 1ns / 100ps

module TestROM_Manual(
        input wire clk,
        input wire [12:0] addr,
        output reg [15:0] data
    );
    
    (* rom_style = "block" *)
    reg [15:0] mem [6800:0];
    
    initial begin
        data <= 15'b0;
    end
    
    always @(posedge clk) begin
        data <= mem[addr];
    end
    
    initial begin
        $readmemh("/home/michele/rsa/test/rom/test_rom_data.hex", mem);
    end

endmodule
