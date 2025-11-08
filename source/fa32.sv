module fa32 (
  input  logic [31:0] A, B,
  input  logic Cin,
  output logic Cout,
  output logic [31:0] S
);

  logic [30:0] C;  // Internal carry wires

  // Instantiate 32 full adders
  fa fa0  (.A(A[0]),  .B(B[0]),  .Cin(Cin),   .Cout(C[0]),  .S(S[0]));
  fa fa1  (.A(A[1]),  .B(B[1]),  .Cin(C[0]),  .Cout(C[1]),  .S(S[1]));
  fa fa2  (.A(A[2]),  .B(B[2]),  .Cin(C[1]),  .Cout(C[2]),  .S(S[2]));
  fa fa3  (.A(A[3]),  .B(B[3]),  .Cin(C[2]),  .Cout(C[3]),  .S(S[3]));
  fa fa4  (.A(A[4]),  .B(B[4]),  .Cin(C[3]),  .Cout(C[4]),  .S(S[4]));
  fa fa5  (.A(A[5]),  .B(B[5]),  .Cin(C[4]),  .Cout(C[5]),  .S(S[5]));
  fa fa6  (.A(A[6]),  .B(B[6]),  .Cin(C[5]),  .Cout(C[6]),  .S(S[6]));
  fa fa7  (.A(A[7]),  .B(B[7]),  .Cin(C[6]),  .Cout(C[7]),  .S(S[7]));
  fa fa8  (.A(A[8]),  .B(B[8]),  .Cin(C[7]),  .Cout(C[8]),  .S(S[8]));
  fa fa9  (.A(A[9]),  .B(B[9]),  .Cin(C[8]),  .Cout(C[9]),  .S(S[9]));
  fa fa10 (.A(A[10]), .B(B[10]), .Cin(C[9]),  .Cout(C[10]), .S(S[10]));
  fa fa11 (.A(A[11]), .B(B[11]), .Cin(C[10]), .Cout(C[11]), .S(S[11]));
  fa fa12 (.A(A[12]), .B(B[12]), .Cin(C[11]), .Cout(C[12]), .S(S[12]));
  fa fa13 (.A(A[13]), .B(B[13]), .Cin(C[12]), .Cout(C[13]), .S(S[13]));
  fa fa14 (.A(A[14]), .B(B[14]), .Cin(C[13]), .Cout(C[14]), .S(S[14]));
  fa fa15 (.A(A[15]), .B(B[15]), .Cin(C[14]), .Cout(C[15]), .S(S[15]));
  fa fa16 (.A(A[16]), .B(B[16]), .Cin(C[15]), .Cout(C[16]), .S(S[16]));
  fa fa17 (.A(A[17]), .B(B[17]), .Cin(C[16]), .Cout(C[17]), .S(S[17]));
  fa fa18 (.A(A[18]), .B(B[18]), .Cin(C[17]), .Cout(C[18]), .S(S[18]));
  fa fa19 (.A(A[19]), .B(B[19]), .Cin(C[18]), .Cout(C[19]), .S(S[19]));
  fa fa20 (.A(A[20]), .B(B[20]), .Cin(C[19]), .Cout(C[20]), .S(S[20]));
  fa fa21 (.A(A[21]), .B(B[21]), .Cin(C[20]), .Cout(C[21]), .S(S[21]));
  fa fa22 (.A(A[22]), .B(B[22]), .Cin(C[21]), .Cout(C[22]), .S(S[22]));
  fa fa23 (.A(A[23]), .B(B[23]), .Cin(C[22]), .Cout(C[23]), .S(S[23]));
  fa fa24 (.A(A[24]), .B(B[24]), .Cin(C[23]), .Cout(C[24]), .S(S[24]));
  fa fa25 (.A(A[25]), .B(B[25]), .Cin(C[24]), .Cout(C[25]), .S(S[25]));
  fa fa26 (.A(A[26]), .B(B[26]), .Cin(C[25]), .Cout(C[26]), .S(S[26]));
  fa fa27 (.A(A[27]), .B(B[27]), .Cin(C[26]), .Cout(C[27]), .S(S[27]));
  fa fa28 (.A(A[28]), .B(B[28]), .Cin(C[27]), .Cout(C[28]), .S(S[28]));
  fa fa29 (.A(A[29]), .B(B[29]), .Cin(C[28]), .Cout(C[29]), .S(S[29]));
  fa fa30 (.A(A[30]), .B(B[30]), .Cin(C[29]), .Cout(C[30]), .S(S[30]));
  fa fa31 (.A(A[31]), .B(B[31]), .Cin(C[30]), .Cout(Cout),  .S(S[31]));

endmodule
