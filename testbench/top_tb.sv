`timescale 1ns/1ps

module top_tb;

    logic clk=0;
    logic rst_pin;
    logic [7:0] led;  // onboard LED but
    // logic rst_pin, J39_b15, J39_c15, J39_b20, J39_e11, J39_b10, 
    // J39_a14, J39_d13, J39_e12, J40_m3, J40_j5, J40_a15, J40_h2, J40_j4, 
    // ,J40_j3, J40_l4, J40_m4, J40_n4, J40_k5;

    // Instantiate DUT
    top dut (
        .clk(clk),
        .rst_pin(rst_pin),
        .led(led)
    );

    // Clock generation: 10ns perio
    always #1 clk = ~clk;

    // Reset pulse
    initial begin
        rst_pin = 0;
        #20;
        rst_pin = 1;
    end

    // Display freeze, enable signals, instructions, and all registers
    always_ff @(posedge clk) begin
        $display("[%0t] freeze1=%b freeze2=%b enable1=%b enable2=%b",
                 $time, dut.freeze1, dut.freeze2,
                 dut.datapath_1_enable, dut.datapath_2_enable);
        $display("         ins0=%h ins1=%h", dut.instruction0, dut.instruction1);
        $display("ALU RESULTS: ALU_result1=%h, ALU_result2=%h",
                 dut.ALU_result1,  dut.ALU_result2);
        

        // Print all registers in the register file
        $display("         Register File:");
        for (int i = 0; i < 32; i++) begin
            $display("           x%0d = %h", i, dut.reg_file_inst.registers[i]);
        end

        // Print cache contents
        $display("         Cache Contents (ins[0:11]):");
        for (int i = 0; i < 12; i++) begin
            $display("           ins[%0d] = %h", i, dut.cache_inst.ins[i]);
        end
    end

    
    initial begin
        $dumpfile("waves/top.vcd");
        $dumpvars(0, top_tb);
        #10000;
        $display("=== DATAPATH SIMULATION COMPLETE ===");
        $finish;
    end

endmodule
