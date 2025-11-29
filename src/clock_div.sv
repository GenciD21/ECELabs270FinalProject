module clock_div (
    input logic clk,
    input logic n_rst,
    input logic [31:0] div,
    output logic new_clk
);

    logic [31:0] counter;

    always_ff @(posedge clk, negedge n_rst) begin
    if (~n_rst) begin
            counter <= 0;
            new_clk <= 0;
        end
        else begin
            if (counter == (div - 1)) begin
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