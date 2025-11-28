module ALU(
  input  logic [31:0] src_A, src_B, instruction,
  input  logic        ALU_control,
  output logic [31:0] ALU_result,
  output logic [6:0] opcode_out
);

  logic [31:0] sub_result;
  logic [6:0]  funct7, opcode;
  logic [2:0]  funct3;

  assign funct3 = instruction[14:12];
  assign funct7 = instruction[31:25];
  assign opcode = instruction[6:0];

  assign opcode_out = opcode;

  // Subtract B from A using fa32 (A - B)
  fa32 subtractor (
    .A(src_A),
    .B(~src_B),
    .Cin(1'b1),
    .Cout(),
    .S(sub_result)
  );

  always_comb begin
    ALU_result = 32'b0;

      // If it's an R-type instruction (opcode == 0110011), use funct3/funct7 logic
      if (opcode == 7'b0110011) begin
        case (funct3)
          3'b000: begin
          if (funct7 == 7'b0000001) begin
            // MUL
            ALU_result = 32'd0; // Let external module drive result later
          end
          else if (funct7 == 7'b0100000) begin
            // SUB
            ALU_result = sub_result;
          end
          else begin
            // ADD
            ALU_result = src_A + src_B;
          end
        end
          3'b111: ALU_result = src_A & src_B;
          3'b110: ALU_result = src_A | src_B;
          3'b100: ALU_result = src_A ^ src_B;
          3'b001: ALU_result = src_A << src_B[4:0];
          3'b101: ALU_result = (funct7 == 7'b0100000) ? 
                               ($signed(src_A) >>> src_B[4:0]) : 
                               (src_A >> src_B[4:0]);
          3'b010: ALU_result = ($signed(src_A) < $signed(src_B)) ? 32'd1 : 32'd0;
          3'b011: ALU_result = ($unsigned(src_A) < $unsigned(src_B)) ? 32'd1 : 32'd0;
          default: ALU_result = 32'd0;
        endcase
      end
      else begin
        // For I-type and S-type instructions like LW/SW/ADDI — just do ADD
        if (opcode == 7'b0010011) begin
          case (funct3)
                3'b000: ALU_result = src_A + src_B;                           // ADDI
                3'b010: ALU_result = ($signed(src_A) < $signed(src_B)) ? 32'd1 : 32'd0; // SLTI
                3'b011: ALU_result = ($unsigned(src_A) < $unsigned(src_B)) ? 32'd1 : 32'd0; // SLTIU
                3'b100: ALU_result = src_A ^ src_B;                           // XORI
                3'b110: ALU_result = src_A | src_B;                           // ORI
                3'b111: ALU_result = src_A & src_B;                           // ANDI
                3'b001: ALU_result = src_A << instruction[24:20];             // SLLI (funct7 must be 0000000)
                3'b101: begin
                  if (instruction[31:25] == 7'b0000000)
                    ALU_result = src_A >> instruction[24:20];                 // SRLI
                  else if (instruction[31:25] == 7'b0100000)
                    ALU_result = $signed(src_A) >>> instruction[24:20];       // SRAI
                  else
                    ALU_result = 32'd0;                                       // Invalid shift
                end
                default: ALU_result = 32'd0;
          endcase
        end
        else begin
          ALU_result = src_A + src_B;
        end
      end
    end
endmodule
