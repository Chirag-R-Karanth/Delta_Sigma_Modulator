`timescale 1ns/1ps

module tb_ddsm;

parameter WIDTH       = 16;
parameter CYCLES      = 65536;
parameter WAVE_CYCLES = 256;

localparam [WIDTH-1:0] FCW = 16'h8000;

reg clk;
reg rst;
reg enable;

reg [WIDTH-1:0] frac_in;

wire first_out;
wire signed [2:0] mash_out;

integer i;

integer first_sum;
integer mash_sum;

integer first_ones;

integer mash_minus1;
integer mash_zero;
integer mash_plus1;
integer mash_plus2;

integer mash_value;

real first_average;
real mash_average;
real expected_fraction;

//================================================
// FIRST ORDER DDSM INSTANCE
//================================================

dsm_first_order #(
.WIDTH(WIDTH)
) u_first (
.clk(clk),
.rst(rst),
.enable(enable),
.frac_in(frac_in),
.dsm_out(first_out)
);

//================================================
// MASH 1-1 DDSM INSTANCE
//================================================

dsm_mash11 #(
.WIDTH(WIDTH)
) u_mash (
.clk(clk),
.rst(rst),
.enable(enable),
.frac_in(frac_in),
.dsm_out(mash_out)
);

//================================================
// 100 MHz CLOCK
//================================================

initial begin
clk = 1'b0;
forever #5 clk = ~clk;
end

//================================================
// MAIN TEST
//================================================

initial begin

// VCD FILE
$dumpfile("dump.vcd");
$dumpvars(0, tb_ddsm);

// INITIALIZATION
rst = 1'b1;
enable = 1'b0;

frac_in = FCW;

first_sum = 0;
mash_sum = 0;

first_ones = 0;

mash_minus1 = 0;
mash_zero = 0;
mash_plus1 = 0;
mash_plus2 = 0;

// RESET FOR FOUR CLOCK CYCLES
repeat (4) @(negedge clk);

rst = 1'b0;
enable = 1'b1;

//============================================
// SIMULATION LOOP
//============================================

for (i = 0; i < CYCLES; i = i + 1) begin

// Sample after rising-edge register updates
@(negedge clk);

// First-order accumulation
first_sum = first_sum + first_out;

if (first_out)
first_ones = first_ones + 1;

// MASH accumulation
mash_value = $signed(mash_out);

mash_sum = mash_sum + mash_value;

case (mash_value)

-1: mash_minus1 = mash_minus1 + 1;

0: mash_zero = mash_zero + 1;

1: mash_plus1 = mash_plus1 + 1;

2: mash_plus2 = mash_plus2 + 1;

default:
$display("ERROR: Invalid MASH output");

endcase

// Stop VCD capture after 256 cycles.
// Numerical simulation continues.

if (i == WAVE_CYCLES-1)
$dumpoff;

end

//============================================
// CALCULATE RESULTS
//============================================

first_average =
first_sum * 1.0 / CYCLES;

mash_average =
mash_sum * 1.0 / CYCLES;

expected_fraction =
FCW * 1.0 / (2.0 ** WIDTH);

//============================================
// DISPLAY RESULTS
//============================================

$display("");
$display("======================================");
$display("       DDSM SIMULATION REPORT");
$display("======================================");

$display("Fractional input = %h", FCW);
$display("Accumulator width = %0d", WIDTH);
$display("Simulation cycles = %0d", CYCLES);

$display("");
$display("FIRST ORDER DDSM");

$display("Output ones = %0d", first_ones);

$display("Output average = %f",
first_average);

$display("");
$display("MASH 1-1 DDSM");

$display("Output -1 = %0d", mash_minus1);
$display("Output  0 = %0d", mash_zero);
$display("Output +1 = %0d", mash_plus1);
$display("Output +2 = %0d", mash_plus2);

$display("Output sum = %0d", mash_sum);

$display("Output average = %f",
mash_average);

$display("");
$display("EXPECTED FRACTION = %f",
expected_fraction);

//============================================
// AUTOMATIC CHECKING
//============================================

$display("");
$display("========== VERIFICATION ==========");

if (first_sum == 13107)
$display("FIRST ORDER: PASS");
else
$display("FIRST ORDER: FAIL");

if (mash_sum == 13107)
$display("MASH 1-1: PASS");
else
$display("MASH 1-1: FAIL");

$display("==================================");

$display("VCD waveform: dump.vcd");
$display("Captured cycles: %0d", WAVE_CYCLES);

$display("==================================");

$finish;

end

endmodule
