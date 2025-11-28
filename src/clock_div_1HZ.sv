module clock_div_1HZ (
    input logic clk,
    input logic n_rst,
    output logic new_clk
);

    logic [31:0] counter;

    always_ff @(posedge clk, negedge n_rst) begin
    if (~n_rst) begin
            counter <= 0;
            new_clk <= 0;
        end
        else begin
            if (counter == 5_000_000) begin
                new_clk <= ~new_clk;
                counter <= 0;
            end
            else begin
                counter <= counter + 1;
            end
        end
    end

//24_999_999
endmodule