
`timescale 1ns/1ps

//============================================================
// MODULE 1: FIRST ORDER DIGITAL DELTA SIGMA MODULATOR
//============================================================

module dsm_first_order #(
    parameter WIDTH = 16
)(
    input  wire                 clk,
    input  wire                 rst,
    input  wire                 enable,
    input  wire [WIDTH-1:0]     frac_in,

    output reg                  dsm_out
);

    reg [WIDTH-1:0] accumulator;

    wire [WIDTH:0] accumulator_sum;

    assign accumulator_sum =
        {1'b0, accumulator} + {1'b0, frac_in};

    always @(posedge clk) begin

        if (rst) begin
            accumulator <= {WIDTH{1'b0}};
            dsm_out     <= 1'b0;
        end

        else if (enable) begin
            accumulator <= accumulator_sum[WIDTH-1:0];
            dsm_out     <= accumulator_sum[WIDTH];
        end

    end

endmodule


//============================================================
// MODULE 2: MASH 1-1 DIGITAL DELTA SIGMA MODULATOR
//============================================================

module dsm_mash11 #(
    parameter WIDTH = 16
)(
    input  wire                 clk,
    input  wire                 rst,
    input  wire                 enable,
    input  wire [WIDTH-1:0]     frac_in,

    output reg signed [2:0]     dsm_out
);

    // Stage 1 accumulator
    reg [WIDTH-1:0] acc1;

    // Stage 2 accumulator
    reg [WIDTH-1:0] acc2;

    // Previous stage-2 carry
    reg carry2_delayed;

    // Stage 1 arithmetic
    wire [WIDTH:0] sum1;

    wire carry1;

    wire [WIDTH-1:0] residue1;

    assign sum1 =
        {1'b0, acc1} + {1'b0, frac_in};

    assign carry1 = sum1[WIDTH];

    assign residue1 = sum1[WIDTH-1:0];

    // Stage 2 arithmetic
    wire [WIDTH:0] sum2;

    wire carry2;

    assign sum2 =
        {1'b0, acc2} + {1'b0, residue1};

    assign carry2 = sum2[WIDTH];

    // Signed digital error cancellation
    // Y[n] = C1[n] + C2[n] - C2[n-1]

    wire signed [3:0] mash_result;

    assign mash_result =
        $signed({3'b000, carry1})
      + $signed({3'b000, carry2})
      - $signed({3'b000, carry2_delayed});

    always @(posedge clk) begin

        if (rst) begin

            acc1 <= {WIDTH{1'b0}};
            acc2 <= {WIDTH{1'b0}};

            carry2_delayed <= 1'b0;

            dsm_out <= 3'sd0;

        end

        else if (enable) begin

            // Update stage 1
            acc1 <= residue1;

            // Update stage 2 using stage-1 residue
            acc2 <= sum2[WIDTH-1:0];

            // Store previous stage-2 carry
            carry2_delayed <= carry2;

            // MASH output
            dsm_out <= mash_result[2:0];

        end

    end

endmodule
