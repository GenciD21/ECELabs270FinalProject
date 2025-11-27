module multiplication (
    input logic clk, rst,
    input logic mul, // this is the enable signal, it should only stay high for one clock cycle to receive inputs
    input logic [31:0] multiplicand, multiplier,
    output logic [31:0] product,
    output logic ack_mul,
    output logic zero_multi
);


logic [31:0] multiplicand_i, multiplicand_i_n; // the internal multiplicand shift register
logic [15:0] multiplier_i, multiplier_i_n; // the internal multiplier shift register
logic [31:0] product_n; // the next product
logic mul_prev;
logic mul_rising_edge;
logic [31:0] multiplicand_past, multiplier_past;

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        mul_prev <= 0;
    end else begin
        mul_prev <= mul;
    end
end



always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
        multiplicand_i <= 0;
        multiplier_i <= 0;
        product <= 0;
        multiplicand_past <= 0;
        multiplier_past <= 0;
    end else begin
        multiplicand_i <= multiplicand_i_n;
        multiplier_i <= multiplier_i_n;
        product <= product_n;
        multiplicand_past <= multiplicand;
        multiplier_past <= multiplier;
    end

end

always_comb begin
    zero_multi = (!multiplicand || !multiplier) && mul;
    mul_rising_edge = mul & ~mul_prev;
    multiplicand_i_n = multiplicand_i;
    multiplier_i_n = multiplier_i;
    product_n = product;
    if (mul_rising_edge || (multiplicand != multiplicand_past) || (multiplier != multiplier_past)) begin
        multiplicand_i_n = {16'd0, multiplicand[15:0]};
        multiplier_i_n = multiplier[15:0];
        product_n = 0;
        ack_mul = 1'b0;
    end else begin
        if (multiplier_i == 16'b0) begin
            ack_mul = 1'b1;
        end else if (multiplier_i[0] == 1'b1) begin
            product_n = product + multiplicand_i;
            ack_mul = 1'b0;
        end else begin
            ack_mul = 1'b0;
        end
        multiplier_i_n = {1'b0,multiplier_i[15:1]};
        multiplicand_i_n = {multiplicand_i[30:0], 1'b0};

    end
end

endmodule
