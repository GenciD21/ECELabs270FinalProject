module alu_7seg_mux(
    input  logic        clk,          
    input  logic [7:0]  alu_result,
    output logic [6:0]  seg,
    output logic [1:0]  digit_en,
    output logic        dp
);

    parameter integer DIVIDER = 100_000;

    logic [16:0] counter = 0;
    logic sel = 0;

    logic [7:0] value_latched;
    logic [3:0] tens;
    logic [3:0] ones;

    always_ff @(posedge clk) begin
        if (counter >= DIVIDER) begin
            counter <= 0;
            sel <= ~sel;
            value_latched <= alu_result;
        end else begin
            counter <= counter + 1;
        end
    end

    always_comb begin
        tens = value_latched / 10;
        ones = value_latched % 10;
    end

    function automatic [6:0] nibble_to_seg;
        input [3:0] nibble;
        begin
            case(nibble)
                4'd0: nibble_to_seg = 7'b1111110;
                4'd1: nibble_to_seg = 7'b0110000;
                4'd2: nibble_to_seg = 7'b1101101;
                4'd3: nibble_to_seg = 7'b1111001;
                4'd4: nibble_to_seg = 7'b0110011;
                4'd5: nibble_to_seg = 7'b1011011;
                4'd6: nibble_to_seg = 7'b1011111;
                4'd7: nibble_to_seg = 7'b1110000;
                4'd8: nibble_to_seg = 7'b1111111;
                4'd9: nibble_to_seg = 7'b1111011;
                default: nibble_to_seg = 7'b0000000;
            endcase
        end
    endfunction

    always_comb begin
        if (sel)
            seg = nibble_to_seg(tens);
        else
            seg = nibble_to_seg(ones);
    end

    always_comb begin
        if (sel)
            digit_en = 2'b01;
        else
            digit_en = 2'b10;
    end

    assign dp = 1'b1;

endmodule
