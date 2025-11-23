module top (
    input  logic clk,       // 100 MHz clock from PCF
    input  logic btn,       // pushbutton
    output logic [7:0] led  // onboard LED bus
);

    // 32-bit counter for blinking
    logic [31:0] counter;

    always_ff @(posedge clk) begin
        counter <= counter + 1;
    end

    // LED assignments
    assign led[0] = counter[25];   // slow blink
    assign led[1] = counter[24];   // faster blink
    assign led[2] = btn;           // button passthrough
    assign led[3] = ~btn;          // inverted button
    assign led[7:4] = counter[31:28]; // fun shifting pattern

endmodule

