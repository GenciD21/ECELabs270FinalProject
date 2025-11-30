module register_file(
  input  logic clk, n_rst, en,
  input  logic reg_write, reg_write2,
  input  logic [4:0] reg1, reg2, reg3, reg4, regd, regd2,
  input  logic [31:0] write_data, write_data2,
  output logic [31:0] read_data1, read_data2, read_data3, read_data4
);
  logic [31:0] registers [31:0];

  always_ff @(posedge clk, negedge n_rst) begin
    
    if (~n_rst) begin
      for (int i = 0; i < 32; i++)
        registers[i] <= 32'd0;
    end 
    else if(en) begin
      // When the register destiation of 1 and 2 are the same, you write_data2 as opposed to data1
      if (reg_write && reg_write2 && (regd == regd2)) begin
        if (regd != 5'd0)
          registers[regd] <= write_data2; // ALU2 priority
      end 

      else begin //Paralllel, Write data1 to registers[index 2^5-1]
        if (reg_write && (regd != 5'd0))
          registers[regd] <= write_data;
        if (reg_write2 && (regd2 != 5'd0))
          registers[regd2] <= write_data2;
      end
    end
  end
  
  // 4 read ports for dual-issue
  assign read_data1 = registers[reg1];
  assign read_data2 = registers[reg2];
  assign read_data3 = registers[reg3];
  assign read_data4 = registers[reg4];
endmodule