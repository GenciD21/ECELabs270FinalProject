`timescale 1ns/1ps

module cache1_tb;

  // Clock and reset
  logic clk;
  logic rst;

  // Inputs to DUT
  logic freeze1;
  logic freeze2;
  logic dependency_on_ins2;

  // Outputs from DUT
  logic nothing_filled;
  logic [31:0] instruction0;
  logic [31:0] instruction1;

  // DUT instance
  cache1 dut (
    .clk(clk),
    .rst(rst),
    .freeze1(freeze1),
    .freeze2(freeze2),
    .dependency_on_ins2(dependency_on_ins2),
    .nothing_filled(nothing_filled),
    .instruction0(instruction0),
    .instruction1(instruction1)
  );

  // Clock generation: 10ns period
  initial clk = 0;
  always #5 clk = ~clk;

  // PC increments every 2 cycles by 8 bytes (simulate fetch advancing)

  // Test control
  initial begin
    $dumpfile("waves/cache1.vcd");
    $dumpvars(0, cache1_tb);
    $display("=== CACHE AUTO-FILL TEST START ===");

    // Reset
    rst = 1;
    freeze1 = 0;
    freeze2 = 0;
    dependency_on_ins2 = 0;

    #20;
    rst = 0;

    // Let simulation run for a while
    repeat (100) begin
      @(posedge clk);
      if ($urandom_range(0, 2) == 0) freeze1 = ~freeze1;
      if ($urandom_range(0, 2) == 0) freeze2 = ~freeze2;
      //if ($urandom_range(0, 4) == 0) dependency_on_ins2 = ~dependency_on_ins2;
      $display("freeze states: freeze1=%b, freeze2=%b, dependency_on_ins2=%b", dut.freeze1, dut.freeze2, dut.dependency_on_ins2);
      $display("[%0t] PC=%h  ins0=%h  ins1=%h  nothing_filled=%b...Second_fill=%b...busy=%b",
               $time, dut.PC, instruction0, instruction1, nothing_filled, dut.second_half_cache_to_fill, dut.busy);
      $write("ins array: ");
      for (int i = 0; i < 12; i++) begin
        $write("%0h ", dut.ins[i]);
      end
      $display(""); // new line
      $write("n_ins array: ");
      for (int i = 0; i < 6; i++) begin
        $write("%0h ", dut.n_ins[i]);
      end
      $display(""); // new line
      $display(""); // new line
    end

    $display("=== CACHE AUTO-FILL TEST DONE ===");
    $finish;
  end

endmodule
