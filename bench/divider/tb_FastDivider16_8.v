`timescale 1ns / 100ps

module tb_FastDivider16_8;
    
    reg clk = 1'b0;
    reg rst = 1'b1;
    reg rng_done = 1'b0;
    reg divisor_ready = 1'b0;
    reg [7:0] divisor = 8'd2;
    
    wire output_ready;
    wire [23:0] output_data;
    
    FastDivider16_8 DUT (
        .aclk                   (clk),
        .aresetn                (~rst),
        .aclken                 (1'b1),
        .s_axis_divisor_tvalid  (divisor_ready),
        .s_axis_divisor_tdata   (divisor),
        .s_axis_dividend_tvalid (rng_done),
        .s_axis_dividend_tdata  (16'd59477),
        .m_axis_dout_tvalid     (output_ready),
        .m_axis_dout_tdata      (output_data)
    );
    
    initial begin
        forever #5 clk = ~clk;
    end
    
    always @(posedge clk) begin
        if (divisor_ready) divisor <= divisor + 1;
    end
    
    initial begin
        #100 rst = 1'b0;
        #200 rng_done = 1'b1;
        #300 divisor_ready = 1'b1;
        #3000 $finish;
    end

endmodule
