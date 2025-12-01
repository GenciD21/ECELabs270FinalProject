`default_nettype none
module ssdec (
  //put your ports here
  input logic [3:0] in,
  input logic enable,
  output logic [6:0] out
);
//your code starts here ...
always_comb begin
  if (!enable) begin
    out = 7'b0000000;
  end
  else begin
    case (in)
      4'h0: begin out = 7'b0111111; end
      4'h1: begin out = 7'b0000110; end
      4'h2: begin out = 7'b1011011; end
      4'h3: begin out = 7'b1001111; end
      4'h4: begin out = 7'b1100110; end
      4'h5: begin out = 7'b1101101; end
      4'h6: begin out = 7'b1111101; end
      4'h7: begin out = 7'b0000111; end
      4'h8: begin out = 7'b1111111; end
      4'h9: begin out = 7'b1100111; end
      4'hA: begin out = 7'b1110111; end
      4'hB: begin out = 7'b1111100; end
      4'hC: begin out = 7'b0111001; end
      4'hD: begin out = 7'b1011110; end
      4'hE: begin out = 7'b1111001; end
      4'hF: begin out = 7'b1110001; end
    endcase

    end
end

endmodule