
`timescale 1ns / 1ps

module tb_first_order_dsm;

    reg clk;
    reg rst;
    reg [3:0] K;

    wire y;
    wire [3:0] acc;

    // Instantiate the design under test.
    first_order_dsm #(
        .W(4)
    ) dut (
        .clk(clk),
        .rst(rst),
        .K(K),
        .y(y),
        .acc(acc)
    );

    // Generate a clock with a 10 ns period.
    initial clk = 0;
    always #5 clk = ~clk;

    // Apply reset and run the simulation.
    initial begin
        rst = 1;
        K   = 4'd4;

        repeat (2) @(posedge clk);

        // Release reset just after a rising edge.
        #1 rst = 0;

        // Observe 20 more rising clock edges.
        repeat (20) @(posedge clk);

        #1 $finish;
    end

endmodule
