`timescale 1ns/1ps

module ALU_mul_tb();
    // Clock and reset
    logic clk, rst;
    
    // ALU signals
    logic [31:0] src_A, src_B, instruction;
    logic        ALU_control;
    logic [31:0] ALU_result;
    logic        BranchConditionFlag;
    logic        MUL_EN;
    
    // Multiplication signals
    logic [31:0] mul_result;
    logic        ack_mul;
    logic        zero_multi;
    
    // Final result (mux between ALU and multiplier)
    logic [31:0] final_result;
    
    // Test variables
    integer test_num;
    logic [31:0] expected_result;

    // DUT instances
    ALU dut (
        .src_A(src_A),
        .src_B(src_B),
        .instruction(instruction),
        .ALU_control(ALU_control),
        .ALU_result(ALU_result),
        .BranchConditionFlag(BranchConditionFlag),
        .MUL_EN(MUL_EN)
    );

    multiplication mul(
        .clk(clk),
        .rst(rst),
        .mul(MUL_EN),
        .multiplicand(src_A),
        .multiplier(src_B),
        .product(mul_result),
        .ack_mul(ack_mul),
        .zero_multi(zero_multi)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns period = 100MHz
    end

    // Select between ALU result and multiplier result
    assign final_result = MUL_EN ? mul_result : ALU_result;

    // Test sequence
    initial begin
        // Initialize
        rst = 1;
        src_A = 32'b0;
        src_B = 32'b0;
        instruction = 32'b0;
        ALU_control = 1'b0;
        test_num = 0;

        $dumpfile("waves/ALU_mul.vcd");
        $dumpvars(0, ALU_mul_tb);

        // Reset
        #20;
        rst = 0;
        #10;

        $display("\n========== ALU + MULTIPLIER TESTBENCH ==========\n");

        // Test 1: Simple ADD (non-multiply)
        test_num = test_num + 1;
        src_A = 32'd10;
        src_B = 32'd15;
        instruction = {7'b0000000, 5'd2, 5'd1, 3'b000, 5'd3, 7'b0110011}; // ADD
        ALU_control = 1'b0;
        expected_result = 32'd25;
        #10;
        $display("Test %0d: ADD - 10 + 15", test_num);
        $display("  Result: %0d | Expected: %0d | MUL_EN: %0d | %s", 
                 final_result, expected_result, MUL_EN,
                 (final_result == expected_result && MUL_EN == 0) ? "PASS" : "FAIL");

        // Test 2: MUL - 6 * 7 = 42
        test_num = test_num + 1;
        src_A = 32'd6;
        src_B = 32'd7;
        instruction = {7'b0000001, 5'd2, 5'd1, 3'b000, 5'd3, 7'b0110011}; // MUL
        expected_result = 32'd42;
        #10; // Wait for MUL_EN to assert
        
        // Wait for multiplication to complete
        wait(ack_mul == 1'b1);
        #10;
        $display("\nTest %0d: MUL - 6 * 7", test_num);
        $display("  Result: %0d | Expected: %0d | MUL_EN: %0d | ack_mul: %0d | %s", 
                 final_result, expected_result, MUL_EN, ack_mul,
                 (final_result == expected_result && MUL_EN == 1) ? "PASS" : "FAIL");

        // Test 3: MUL - 12 * 5 = 60
        test_num = test_num + 1;
        src_A = 32'd12;
        src_B = 32'd5;
        instruction = {7'b0000001, 5'd2, 5'd1, 3'b000, 5'd3, 7'b0110011}; // MUL
        expected_result = 32'd60;
        #10;
        
        wait(ack_mul == 1'b1);
        #10;
        $display("\nTest %0d: MUL - 12 * 5", test_num);
        $display("  Result: %0d | Expected: %0d | %s", 
                 final_result, expected_result,
                 (final_result == expected_result) ? "PASS" : "FAIL");

        // Test 4: MUL - 100 * 50 = 5000
        test_num = test_num + 1;
        src_A = 32'd100;
        src_B = 32'd50;
        instruction = {7'b0000001, 5'd2, 5'd1, 3'b000, 5'd3, 7'b0110011}; // MUL
        expected_result = 32'd5000;
        #10;
        
        wait(ack_mul == 1'b1);
        #10;
        $display("\nTest %0d: MUL - 100 * 50", test_num);
        $display("  Result: %0d | Expected: %0d | %s", 
                 final_result, expected_result,
                 (final_result == expected_result) ? "PASS" : "FAIL");

        // Test 5: MUL - 255 * 255 = 65025
        test_num = test_num + 1;
        src_A = 32'd255;
        src_B = 32'd255;
        instruction = {7'b0000001, 5'd2, 5'd1, 3'b000, 5'd3, 7'b0110011}; // MUL
        expected_result = 32'd65025;
        #10;
        
        wait(ack_mul == 1'b1);
        #10;
        $display("\nTest %0d: MUL - 255 * 255", test_num);
        $display("  Result: %0d | Expected: %0d | %s", 
                 final_result, expected_result,
                 (final_result == expected_result) ? "PASS" : "FAIL");

        // Test 6: MUL with zero - 100 * 0 = 0
        test_num = test_num + 1;
        src_A = 32'd100;
        src_B = 32'd0;
        instruction = {7'b0000001, 5'd2, 5'd1, 3'b000, 5'd3, 7'b0110011}; // MUL
        expected_result = 32'd0;
        #10;
        
        if (zero_multi) begin
            $display("\nTest %0d: MUL - 100 * 0 (zero detected)", test_num);
            $display("  zero_multi flag set correctly | PASS");
        end else begin
            wait(ack_mul == 1'b1);
            #10;
            $display("\nTest %0d: MUL - 100 * 0", test_num);
            $display("  Result: %0d | Expected: %0d | %s", 
                     final_result, expected_result,
                     (final_result == expected_result) ? "PASS" : "FAIL");
        end

        // Test 7: Back to regular ALU - SUB
        test_num = test_num + 1;
        src_A = 32'd50;
        src_B = 32'd30;
        instruction = {7'b0100000, 5'd2, 5'd1, 3'b000, 5'd3, 7'b0110011}; // SUB
        expected_result = 32'd20;
        #10;
        $display("\nTest %0d: SUB - 50 - 30", test_num);
        $display("  Result: %0d | Expected: %0d | MUL_EN: %0d | %s", 
                 final_result, expected_result, MUL_EN,
                 (final_result == expected_result && MUL_EN == 0) ? "PASS" : "FAIL");

        // Test 8: XOR
        test_num = test_num + 1;
        src_A = 32'hAAAA5555;
        src_B = 32'h5555AAAA;
        instruction = {7'b0000000, 5'd2, 5'd1, 3'b100, 5'd3, 7'b0110011}; // XOR
        expected_result = 32'hFFFFFFFF;
        #10;
        $display("\nTest %0d: XOR - 0x%h ^ 0x%h", test_num, src_A, src_B);
        $display("  Result: 0x%h | Expected: 0x%h | %s", 
                 final_result, expected_result,
                 (final_result == expected_result) ? "PASS" : "FAIL");

        $display("\n========== ALL TESTS COMPLETE ==========\n");
        #50;
        $finish;
    end

    // Timeout watchdog
    initial begin
        #100000; // 100us timeout
        $display("\nERROR: Testbench timeout!");
        $finish;
    end

endmodule