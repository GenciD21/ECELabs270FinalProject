module clock_div_1HZ (
    input logic clk,
    input logic rst,
    output logic new_clk
);

    logic [31:0] counter;

    always_ff @(posedge clk or negedge n_rst) begin
    if (~rst) begin
            counter <= 0;
            new_clk <= 0;
        end
        else begin
            if (counter == 1) begin
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