module ALU_tb;
  logic [31:0] src_A, src_B, instruction;
  logic        ALU_control;
  logic [31:0] ALU_result;
  logic        BranchConditionFlag;
  logic        MUL_EN;
  
  logic [31:0] expected_result;
  logic        expected_branch;
  logic        expected_mul_en;
  integer      test_num;

  ALU dut (.*);

  initial begin
    src_A = 32'b0; src_B = 32'b0; instruction = 32'b0;
    ALU_control = 1'b0;
    test_num = 0;

    $dumpfile("waves/ALU.vcd");
    $dumpvars(0, ALU_tb);

    $display("\n========== ALU TESTBENCH ==========\n");

    // Test 1: ADD
    test_num = test_num + 1;
    src_A = 32'd10; src_B = 32'd15;
    instruction = {7'b0000000, 5'd2, 5'd1, 3'b000, 5'd3, 7'b0110011};
    ALU_control = 1'b0;
    expected_result = 32'd25;
    expected_mul_en = 1'b0;
    #1;
    $display("Test %0d: ADD - 10 + 15", test_num);
    $display("  Result: %0d | Expected: %0d | %s", ALU_result, expected_result, 
             (ALU_result == expected_result) ? "PASS" : "FAIL");
    #1;

    // Test 2: SUB
    test_num = test_num + 1;
    src_A = 32'd15; src_B = 32'd10;
    instruction = {7'b0100000, 5'd2, 5'd1, 3'b000, 5'd3, 7'b0110011};
    expected_result = 32'd5;
    expected_mul_en = 1'b0;
    #1;
    $display("\nTest %0d: SUB - 15 - 10", test_num);
    $display("  Result: %0d | Expected: %0d | %s", ALU_result, expected_result,
             (ALU_result == expected_result) ? "PASS" : "FAIL");
    #1;

    // Test 3: AND
    test_num = test_num + 1;
    src_A = 32'hFFFF00FF; src_B = 32'hFF00FFFF;
    instruction = {7'b0, 5'd2, 5'd1, 3'b111, 5'd3, 7'b0110011};
    expected_result = 32'hFF0000FF;
    expected_mul_en = 1'b0;
    #1;
    $display("\nTest %0d: AND - 0x%h & 0x%h", test_num, src_A, src_B);
    $display("  Result: 0x%h | Expected: 0x%h | %s", ALU_result, expected_result,
             (ALU_result == expected_result) ? "PASS" : "FAIL");
    #1;

    // Test 4: OR
    test_num = test_num + 1;
    src_A = 32'hFFFF0000; src_B = 32'h0000FFFF;
    instruction = {7'b0, 5'd2, 5'd1, 3'd6, 5'd3, 7'b0110011};
    expected_result = 32'hFFFFFFFF;
    expected_mul_en = 1'b0;
    #1;
    $display("\nTest %0d: OR - 0x%h | 0x%h", test_num, src_A, src_B);
    $display("  Result: 0x%h | Expected: 0x%h | %s", ALU_result, expected_result,
             (ALU_result == expected_result) ? "PASS" : "FAIL");
    #1;

    // Test 5: SRL
    test_num = test_num + 1;
    src_A = 32'hF0000000; src_B = 32'd4;
    instruction = {7'b0, 5'd2, 5'd1, 3'd5, 5'd3, 7'b0110011};
    expected_result = 32'h0F000000;
    expected_mul_en = 1'b0;
    #1;
    $display("\nTest %0d: SRL - 0x%h >> %0d", test_num, src_A, src_B);
    $display("  Result: 0x%h | Expected: 0x%h | %s", ALU_result, expected_result,
             (ALU_result == expected_result) ? "PASS" : "FAIL");
    #1;

    // Test 6: SRA
    test_num = test_num + 1;
    src_A = 32'hF0000000; src_B = 32'd4;
    instruction = {7'b0100000, 5'd2, 5'd1, 3'b101, 5'd3, 7'b0110011};
    expected_result = 32'hFF000000;
    expected_mul_en = 1'b0;
    #1;
    $display("\nTest %0d: SRA - 0x%h >>> %0d (arithmetic)", test_num, src_A, src_B);
    $display("  Result: 0x%h | Expected: 0x%h | %s", ALU_result, expected_result,
             (ALU_result == expected_result) ? "PASS" : "FAIL");
    #1;

    // Test 7: XOR
    test_num = test_num + 1;
    src_A = 32'hAAAA5555; src_B = 32'h5555AAAA;
    instruction = {7'b0000000, 5'd2, 5'd1, 3'b100, 5'd3, 7'b0110011};
    expected_result = 32'hFFFFFFFF;
    expected_mul_en = 1'b0;
    #1;
    $display("\nTest %0d: XOR - 0x%h ^ 0x%h", test_num, src_A, src_B);
    $display("  Result: 0x%h | Expected: 0x%h | %s", ALU_result, expected_result,
             (ALU_result == expected_result) ? "PASS" : "FAIL");
    #1;

    // Test 8: SLL
    test_num = test_num + 1;
    src_A = 32'h00000001; src_B = 32'd8;
    instruction = {7'b0000000, 5'd2, 5'd1, 3'b001, 5'd3, 7'b0110011};
    expected_result = 32'h00000100;
    expected_mul_en = 1'b0;
    #1;
    $display("\nTest %0d: SLL - 0x%h << %0d", test_num, src_A, src_B);
    $display("  Result: 0x%h | Expected: 0x%h | %s", ALU_result, expected_result,
             (ALU_result == expected_result) ? "PASS" : "FAIL");
    #1;

    // Test 9: SLT (signed)
    test_num = test_num + 1;
    src_A = -32'sd1; src_B = 32'sd1;
    instruction = {7'b0000000, 5'd2, 5'd1, 3'b010, 5'd3, 7'b0110011};
    expected_result = 32'd1;
    expected_mul_en = 1'b0;
    #1;
    $display("\nTest %0d: SLT - -1 < 1 (signed)", test_num);
    $display("  Result: %0d | Expected: %0d | %s", ALU_result, expected_result,
             (ALU_result == expected_result) ? "PASS" : "FAIL");
    #1;

    // Test 10: SLTU (unsigned)
    test_num = test_num + 1;
    src_A = 32'h00000001; src_B = 32'hFFFFFFFF;
    instruction = {7'b0000000, 5'd2, 5'd1, 3'b011, 5'd3, 7'b0110011};
    expected_result = 32'd1;
    expected_mul_en = 1'b0;
    #1;
    $display("\nTest %0d: SLTU - 1 < 0xFFFFFFFF (unsigned)", test_num);
    $display("  Result: %0d | Expected: %0d | %s", ALU_result, expected_result,
             (ALU_result == expected_result) ? "PASS" : "FAIL");
    #1;

    // Test 11: MUL (should set MUL_EN)
    test_num = test_num + 1;
    src_A = 32'd6; src_B = 32'd7;
    instruction = {7'b0000001, 5'd2, 5'd1, 3'b000, 5'd3, 7'b0110011}; // MUL instruction
    expected_result = 32'd0;  // ALU returns 0 when MUL_EN is set
    expected_mul_en = 1'b1;
    #1;
    $display("\nTest %0d: MUL - 6 * 7 (should set MUL_EN)", test_num);
    $display("  MUL_EN: %0d | Expected: %0d | %s", MUL_EN, expected_mul_en,
             (MUL_EN == expected_mul_en) ? "PASS" : "FAIL");
    $display("  ALU_result: 0x%h (should be 0 for MUL)", ALU_result);
    #1;

    // Test 12: MUL with larger numbers
    test_num = test_num + 1;
    src_A = 32'd100; src_B = 32'd50;
    instruction = {7'b0000001, 5'd2, 5'd1, 3'b000, 5'd3, 7'b0110011};
    expected_mul_en = 1'b1;
    #1;
    $display("\nTest %0d: MUL - 100 * 50", test_num);
    $display("  MUL_EN: %0d | Expected: %0d | %s", MUL_EN, expected_mul_en,
             (MUL_EN == expected_mul_en) ? "PASS" : "FAIL");
    #1;

    // Branch Tests (ALU_control = 1)
    $display("\n========== BRANCH TESTS ==========\n");
    ALU_control = 1'b1;

    // Test 13: BEQ (equal)
    test_num = test_num + 1;
    src_A = 32'd42; src_B = 32'd42;
    instruction = {7'b0000000, 5'd2, 5'd1, 3'b000, 5'd0, 7'b1100011};
    expected_branch = 1'b1;
    #1;
    $display("Test %0d: BEQ - %0d == %0d", test_num, src_A, src_B);
    $display("  BranchFlag: %0d | Expected: %0d | %s", BranchConditionFlag, expected_branch,
             (BranchConditionFlag == expected_branch) ? "PASS" : "FAIL");
    #1;

    // Test 14: BNE (not equal)
    test_num = test_num + 1;
    src_A = 32'd42; src_B = 32'd24;
    instruction = {7'b0000000, 5'd2, 5'd1, 3'b001, 5'd0, 7'b1100011};
    expected_branch = 1'b1;
    #1;
    $display("\nTest %0d: BNE - %0d != %0d", test_num, src_A, src_B);
    $display("  BranchFlag: %0d | Expected: %0d | %s", BranchConditionFlag, expected_branch,
             (BranchConditionFlag == expected_branch) ? "PASS" : "FAIL");
    #1;

    // Test 15: BLT (less than, signed)
    test_num = test_num + 1;
    src_A = -32'sd5; src_B = 32'sd2;
    instruction = {7'b0000000, 5'd2, 5'd1, 3'b100, 5'd0, 7'b1100011};
    expected_branch = 1'b1;
    #1;
    $display("\nTest %0d: BLT - -5 < 2 (signed)", test_num);
    $display("  BranchFlag: %0d | Expected: %0d | %s", BranchConditionFlag, expected_branch,
             (BranchConditionFlag == expected_branch) ? "PASS" : "FAIL");
    #1;

    // Test 16: BGE (greater or equal, signed)
    test_num = test_num + 1;
    src_A = 32'sd5; src_B = 32'sd2;
    instruction = {7'b0000000, 5'd2, 5'd1, 3'b101, 5'd0, 7'b1100011};
    expected_branch = 1'b1;
    #1;
    $display("\nTest %0d: BGE - 5 >= 2 (signed)", test_num);
    $display("  BranchFlag: %0d | Expected: %0d | %s", BranchConditionFlag, expected_branch,
             (BranchConditionFlag == expected_branch) ? "PASS" : "FAIL");
    #1;

    // Test 17: BLTU (less than, unsigned)
    test_num = test_num + 1;
    src_A = 32'h00000001; src_B = 32'hFFFFFFFF;
    instruction = {7'b0000000, 5'd2, 5'd1, 3'b110, 5'd0, 7'b1100011};
    expected_branch = 1'b1;
    #1;
    $display("\nTest %0d: BLTU - 1 < 0xFFFFFFFF (unsigned)", test_num);
    $display("  BranchFlag: %0d | Expected: %0d | %s", BranchConditionFlag, expected_branch,
             (BranchConditionFlag == expected_branch) ? "PASS" : "FAIL");
    #1;

    // Test 18: BGEU (greater or equal, unsigned)
    test_num = test_num + 1;
    src_A = 32'hFFFFFFFF; src_B = 32'h00000001;
    instruction = {7'b0000000, 5'd2, 5'd1, 3'b111, 5'd0, 7'b1100011};
    expected_branch = 1'b1;
    #1;
    $display("\nTest %0d: BGEU - 0xFFFFFFFF >= 1 (unsigned)", test_num);
    $display("  BranchFlag: %0d | Expected: %0d | %s", BranchConditionFlag, expected_branch,
             (BranchConditionFlag == expected_branch) ? "PASS" : "FAIL");
    #1;

    $display("\n========== ALL TESTS COMPLETE ==========\n");
    $finish;
  end

endmodule