module clk_divider(
    input logic clk,
    input logic rst,
    output logic clk_d
);
    logic counter;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 1'b0;
            clk_d <= 1'b0;
        end else begin
            counter <= ~counter;
            if (counter == 1'b1) begin
                clk_d <= ~clk_d;
            end
        end
    end
endmodule