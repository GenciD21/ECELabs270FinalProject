`timescale 1ns/1ps

module top_tb;

    logic hz100=0;
    logic reset;
    logic [20:0] pb;
    logic [7:0] left, right;
    logic [7:0] ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0;
    logic       red, green, blue;
    logic [7:0] txdata;
    logic [7:0] rxdata;
    logic      txclk, rxclk;
    logic       txready, rxready;

    // Instantiate DUT
    top dut (
        .hz100(hz100),
        .reset(reset)
    );

    // Clock generation: 10ns perio
    always #1 hz100 = ~hz100;

    // Reset pulse
    initial begin
        reset = 1;
        #1;
        reset = 0;
    end

    // Display freeze, enable signals, instructions, and all registers
    always_ff @(posedge hz100) begin
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
        #1000;
        $display("=== DATAPATH SIMULATION COMPLETE ===");
        $finish;
    end

endmodule
