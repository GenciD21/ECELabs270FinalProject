module system_top (
  input        hz100, reset,
  input  [20:0] pb,
  output [7:0] left, right,
  output [7:0] ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
  output       red, green, blue,
  output [7:0] txdata,
  input  [7:0] rxdata,
  output       txclk, rxclk,
  input        txready, rxready
);
    module alu_7seg_mux(
    .clk(hz100)          
    .input(8'hFF);
    .seg(ss7)
    output logic [1:0]  digit_en,
    output logic        dp);

 

endmodule