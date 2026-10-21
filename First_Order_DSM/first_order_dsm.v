
module first_order_dsm #(
    parameter W = 4
)(
    input  wire         clk,
    input  wire         rst,
    input  wire [W-1:0] K,

    output reg          y,
    output reg  [W-1:0] acc
);

    wire [W:0] sum;

    // Add the input to the current accumulator.
    // The extra bit preserves the carry-out.
    assign sum = {1'b0, acc} + {1'b0, K};

    always @(posedge clk) begin
        if (rst) begin
            acc <= 0;
            y   <= 0;
        end
        else begin
            acc <= sum[W-1:0];
            y   <= sum[W];
        end
    end

endmodule
