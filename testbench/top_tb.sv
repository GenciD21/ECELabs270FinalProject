`timescale 1ns/1ps

module top_tb;

    logic clk=0;
    logic rst;
    logic [7:0] led;  // onboard LED but
    // logic rst_pin, J39_b15, J39_c15, J39_b20, J39_e11, J39_b10, 
    // J39_a14, J39_d13, J39_e12, J40_m3, J40_j5, J40_a15, J40_h2, J40_j4, 
    // ,J40_j3, J40_l4, J40_m4, J40_n4, J40_k5;

    // Instantiate DUT
    top dut (
        .clk(clk),
        .rst_pin(rst),
        .led(led)
    );

    // Clock generation: 10ns perio
    always #5 clk = ~clk;

    // Reset pulse
    initial begin
        rst = 1;
        #20;
        rst = 0;
    end
    
    initial begin
        $dumpfile("waves/top.vcd");
        $dumpvars(0, top_tb);
        #700;
        $display("=== DATAPATH SIMULATION COMPLETE ===");
        $finish;
    end

endmodule
