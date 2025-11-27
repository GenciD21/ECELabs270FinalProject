module control_unit (
  input logic [31:0] instruction,
  output logic RegWrite, ALUSrc, MemRead, MemWrite, MemToReg, Jal, Jalr, //ELIMINATING BRANCH
  output logic signed [31:0] Imm,
  output logic ALU_control,
  output logic [4:0] RegD, Reg2, Reg1
);

  logic [6:0] r, i, l, s, b, jalr, jal;
  assign b = 7'b1100011;
  assign r = 7'b0110011;
  assign i = 7'b0010011;
  assign l = 7'b0000011;
  assign s = 7'b0100011;
  assign jalr = 7'b1100111;
  assign jal = 7'b1101111;

  logic [6:0] opcode;
  assign opcode = instruction[6:0];

  assign RegD = instruction[11:7];
  assign Reg1 = instruction[19:15];
  assign Reg2 = instruction[24:20];

  always_comb begin
    Imm = 32'd0;
    Jal = (opcode == jal);
    Jalr = (opcode == jalr);
    ALUSrc = (opcode == i || opcode == l || opcode == s);
    MemRead = (opcode == l);
    MemToReg = (opcode == l);
    MemWrite = (opcode == s);
    RegWrite = (opcode == jal || opcode == jalr || opcode == l || opcode == r || opcode == i);

    if (opcode == b) begin
      ALU_control = 1;
    end
    else begin
      ALU_control = 0;
    end
    

    case (opcode)
      i, l, jalr: begin Imm = {{20{instruction[31]}}, instruction[31:20]}; end
      s:          begin Imm = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]}; end
      b:          begin Imm = ({{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0}); end
      jal:        begin Imm = {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0}; end
      default:    begin Imm = 32'b0; end
    endcase
  end
endmodule