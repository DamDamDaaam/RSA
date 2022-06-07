`timescale 1ns / 100ps

//Combinational binary to BCD converter using unrolled double dabble algorithm

module ConverterBCD_Comb (
    input wire [31:0] bin,
    output wire [39:0] bcd
    );
    
    assign bcd[39] = 1'b0;
    assign bcd[0] = bin[0];
    
    genvar bd; //bcd digit
    genvar si; //shift index
    generate
        for (bd = 1; bd < 10; bd = bd + 1) begin : b
            for (si = 3*bd; si < 32; si = si + 1) begin : s
            
                wire b1_in, b2_in, b3_in, b4_in;
                wire b1_out, b2_out, b3_out, b4_out;
                
                //Connecting all AddThree module inputs
                if (si == 3*bd) begin //special case: first module of a row
                    assign b4_in = 1'b0;
                    if (bd == 1) begin //special case: lowest row
                        assign b1_in = bin[29];
                        assign b2_in = bin[30];
                        assign b3_in = bin[31];
                    end
                    else begin //any other row
                        assign b1_in = b[bd - 1].s[si - 1].b4_out;
                        assign b2_in = b[bd - 1].s[si - 2].b4_out;
                        assign b3_in = b[bd - 1].s[si - 3].b4_out;
                    end
                end
                else begin //any other module of a row
                    assign b2_in = b[bd].s[si - 1].b1_out;
                    assign b3_in = b[bd].s[si - 1].b2_out;
                    assign b4_in = b[bd].s[si - 1].b3_out;
                    if (bd == 1) begin //special case: lowest row
                        assign b1_in = bin[32 - si];
                    end
                    else
                        assign b1_in = b[bd - 1].s[si - 1].b4_out; //any other row
                end
                
                //Connecting outputs from the last modules of all rows to converter outputs
                if (si == 31) begin
                    assign bcd[4*bd - 3] = b1_out;
                    assign bcd[4*bd - 2] = b2_out;
                    assign bcd[4*bd - 1] = b3_out;
                    assign bcd[4*bd    ] = b4_out;
                end
                
                //AddThree module instance
                AddThree inst (
                    .in({b4_in, b3_in, b2_in, b1_in}),
                    .out({b4_out, b3_out, b2_out, b1_out})
                );
                
            end
        end
    endgenerate
    
    assign bcd[37] = b[9].s[30].b4_out; //These converter outputs were left out in the loop
    assign bcd[38] = b[9].s[29].b4_out;
    
endmodule
