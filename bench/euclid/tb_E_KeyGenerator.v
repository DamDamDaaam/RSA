`timescale 1ns / 100ps

module tb_E_KeyGenerator;
    
    //DUT outputs
    wire valid;
    wire [31:0] e_key;
    
    //DUT inputs
    reg clk = 1'b0;
    reg rst = 1'b1;
    reg en  = 1'b0;
    
    reg [31:0] seed = 32'hBABA;
    reg [31:0] phi;
    
    ///////////////////////
    // Device under test //
    ///////////////////////
    
    E_KeyGenerator DUT (
        .clk   (clk  ),
        .rst   (rst  ),
        .en    (en   ),
        
        .seed  (seed ),
        .phi   (phi  ),
        
        .valid (valid),
        .e_key (e_key)
    );
    
    //////////////////////////////
    // Other simulation devices //
    //////////////////////////////
    
    initial begin
        forever #5 clk = ~clk;
    end
    
    RNG_Simulator rng_sim (
        .clk     (clk       ),
        .rst     (rst       ),
        .en      (DUT.rng_en),
        .rng_out (DUT.rng_e )
    );
    
    ///////////////////
    // Main stimulus //
    ///////////////////
    
    initial begin
        #100 rst = 1'b0;
        #50  phi = 32'd4157295846; //Prime factors are 2, 3, 11 and 62989331
        #50  en  = 1'b1;
        #10000 $finish;
    end
    
endmodule
