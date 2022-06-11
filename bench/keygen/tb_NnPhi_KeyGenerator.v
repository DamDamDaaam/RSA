`timescale 1ns / 100ps

module tb_NnPhi_KeyGenerator;
    
    reg clk = 1'b0;
    reg rst = 1'b1;
    reg start = 1'b0;
    reg [12:0] random = $urandom_range(0, 8191);
    
    wire rng_en;
    wire [31:0] n_key;
    wire [31:0] phi;
    wire n_key_valid;
    wire phi_valid;
    
    NnPhi_KeyGenerator DUT (
        .clk         (clk),
        .rst         (rst),
        .start       (start),
        .random      (random),
        .rng_en      (rng_en),
        .n_key       (n_key),
        .phi         (phi),
        .n_key_valid (n_key_valid),
        .phi_valid   (phi_valid)
    );
    
    initial begin
        forever #5 clk = ~clk;
    end
    
    always @(posedge clk) begin
        if (rng_en)
            random <= $urandom_range(0, 8191);
    end
    
    initial begin
        #55   rst = 1'b0;
        #50   start = 1'b1;
        #10   start = 1'b0;
        #1000 $finish;
    end
    
endmodule
