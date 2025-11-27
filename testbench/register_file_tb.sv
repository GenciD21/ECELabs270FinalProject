`timescale 1ns / 1ps

module register_file_tb;

  logic clk, rst, reg_write;
  logic [4:0] reg1, reg2, regd;
  logic [31:0] write_data;
  logic [31:0] read_data1, read_data2;


  register_file r1 (
    .clk(clk),
    .rst(rst),
    .reg_write(reg_write),
    .reg1(reg1),
    .reg2(reg2),
    .regd(regd),
    .write_data(write_data),
    .read_data1(read_data1),
    .read_data2(read_data2)
  );


  always #5 clk = ~clk; 


  initial begin
    $dumpfile("waves/register_file.vcd");
    $dumpvars(0, register_file_tb);


    clk = 0;
    rst = 1;
    reg_write = 0;
    reg1 = 0; reg2 = 0; regd = 0;
    write_data = 0;

  
    #10 rst = 0;

   
    regd = 5;
    write_data = 32'hDEADBEEF;
    reg_write = 1;
    #10;
    reg_write = 0;

    reg1 = 5;
    #10;

 
    regd = 0;
    write_data = 32'h12345678;
    reg_write = 1;
    #10;
    reg_write = 0;

    reg1 = 0;
    #10;

    
    regd = 10;
    write_data = 32'hAABBCCDD;
    reg_write = 1;
    #10;

    regd = 11;
    write_data = 32'h11223344;
    #10;

    reg_write = 0;
    reg1 = 10;
    reg2 = 11;
    #10;

    rst = 1;
    #10;
    

    $display("Simulation finished.");
    #10 $finish;
  end

endmodule
