module reset_on_start(
    output logic reset,
    input logic clk,
    input logic manual
);
  logic [2:0] startup = 4;
  assign reset = startup[2] | manual;    // MSB drives the reset signal
  always @ (posedge clk, posedge manual)
    if (manual == 1)
      startup <= 4;             // start with reset low to get a rising edge
    else begin
        case(startup)
            4: startup <= 5;
            5: startup <= 6;
            6: startup <= 7;
            7: startup <= 0;    // pull reset low here
        endcase
    end
endmodule