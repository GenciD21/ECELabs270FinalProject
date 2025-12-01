module bin8_to_bcd3 (
    input  logic [7:0] bin,
    output logic [3:0] hundreds,
    output logic [3:0] tens,
    output logic [3:0] ones
);

    integer i;
    logic [19:0] shift;  // 8 bits input + 12 bits BCD

    always_comb begin
        shift = 20'd0;
        shift[7:0] = bin;

        for (i = 0; i < 8; i = i + 1) begin
            if (shift[11:8]  >= 5) shift[11:8]  += 3;
            if (shift[15:12] >= 5) shift[15:12] += 3;
            if (shift[19:16] >= 5) shift[19:16] += 3;
            shift = shift << 1;
        end

        ones     = shift[11:8];
        tens     = shift[15:12];
        hundreds = shift[19:16];
    end


endmodule
