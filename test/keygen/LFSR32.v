`timescale 1ns / 100ps

module LFSR32 (
    input wire clk,
    input wire rst,
    input wire en,
    output reg [31:0] rng_out
    );
    
    //Taps: 32, 31, 29, 1
    wire feedback;
    
    assign feedback = rng_out[31];
    
    always @(posedge clk) begin
        if (rst)
            rng_out <= 32'b11010100101001010110101010101101;
        else if (en) begin
            rng_out[0] <= feedback;
            rng_out[1] <= rng_out[0];
            rng_out[2] <= rng_out[1];
            rng_out[3] <= rng_out[2];
            rng_out[4] <= rng_out[3];
            rng_out[5] <= rng_out[4];
            rng_out[6] <= rng_out[5];
            rng_out[7] <= rng_out[6];
            rng_out[8] <= rng_out[7];
            rng_out[9] <= rng_out[8];
            rng_out[10] <= rng_out[9];
            rng_out[11] <= rng_out[10];
            rng_out[12] <= rng_out[11];
            rng_out[13] <= rng_out[12];
            rng_out[14] <= rng_out[13];
            rng_out[15] <= rng_out[14];
            rng_out[16] <= rng_out[15];
            rng_out[17] <= rng_out[16];
            rng_out[18] <= rng_out[17];
            rng_out[19] <= rng_out[18];
            rng_out[20] <= rng_out[19];
            rng_out[21] <= rng_out[20];
            rng_out[22] <= rng_out[21];
            rng_out[23] <= rng_out[22];
            rng_out[24] <= rng_out[23];
            rng_out[25] <= rng_out[24];
            rng_out[26] <= rng_out[25];
            rng_out[27] <= rng_out[26];
            rng_out[28] <= rng_out[27] ^ feedback;
            rng_out[29] <= rng_out[28];
            rng_out[30] <= rng_out[29] ^ feedback;
            rng_out[31] <= rng_out[30] ^ feedback;
        end
    end

endmodule
