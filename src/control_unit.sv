module control_unit (
  input logic [31:0] instruction,
  output logic ALUSrc,
  output logic signed [31:0] Imm,
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
    ALUSrc = (opcode == i || opcode == l || opcode == s);
  
    case (opcode)
      i, l, jalr: begin Imm = {{20{instruction[31]}}, instruction[31:20]}; end
      default:    begin Imm = 32'b0; end
    endcase
  end
endmodule