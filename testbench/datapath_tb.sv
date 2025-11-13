`timescale 1ns/1ps

module datapath_tb;

    logic clk;
    logic rst;

    // Instantiate DUT
    datapath dut (
        .clk(clk),
        .rst(rst)
    );

    // Clock generation: 10ns period
    initial clk = 0;
    always #5 clk = ~clk;

    // Reset pulse
    initial begin
        rst = 1;
        #20;
        rst = 0;
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
    end

    // Stop simulation after some time
    initial begin
        $dumpfile("waves/datapath.vcd");
        $dumpvars(0, datapath_tb);
        #1000;
        $display("=== DATAPATH SIMULATION COMPLETE ===");
        $finish;
    end

endmodule
