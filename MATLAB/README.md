# MASH 1-1 vs MASH 1-1-1 — MATLAB study

This folder adds a MATLAB-only simulation and graphical comparison of second- and third-order cascaded MASH modulators. Existing repository files are retained.

## Requirements
- MATLAB R2016b or newer (the scripts use local functions in scripts).
- No Communications Toolbox or DSP System Toolbox required.

## Run
From the repository root in MATLAB:

```matlab
cd MATLAB
run_comparison
```

Figures and CSV summaries are written to `MATLAB/results/`.

## Model and conventions
Each stage is a first-order, 1-bit error-feedback accumulator with a normalized input in [0,1):
`v[n] = x[n] + s[n-1]`, `q[n] = floor(v[n])`, `s[n] = v[n]-q[n]`.
The residue `s[n]` is fed to the next stage.

With `D(z)=1-z^{-1}`, the stage relation is `Q_i = U_i - D S_i`. Therefore the cancellation combinations are:

- MASH 1-1: `Y = Q1 + D Q2 = Q1 + Q2 - z^-1 Q2`.
- MASH 1-1-1: `Y = Q1 + D Q2 + D^2 Q3`.

The idealized NTFs are `-D^2` and `-D^3` respectively (the minus sign does not affect magnitude/PSD). The existing MASH 1-1 expression in `testbench and design in icarus/dsm.m` already uses the correct plus-derivative cancellation convention; it is intentionally not altered. The earlier claim that its sign was wrong would be incorrect.

## Experiments
The runner performs:
1. DC tests at 0.25, 0.50 and 0.75.
2. A sinusoid centered at 0.5 with amplitude 0.2.
3. Time-domain output and error plots.
4. Output/error PSDs and ideal NTF magnitude responses.
5. In-band error power and SNR estimates.
6. An OSR sweep for the sinusoidal test.
7. Mean-output checks and a CSV summary.

## Interpretation cautions
This is a behavioral, floating-point accumulator model, not a bit-accurate fixed-width RTL model. The ideal NTF assumes linearized quantization noise and exact cancellation. The deterministic 1-bit quantizer can produce idle tones/limit cycles, especially for DC inputs. Treat the PSD as a deterministic sequence spectrum, not proof that quantization error is white. SNR here is estimated from in-band output power after excluding the fundamental tone bin; in-band error power is also reported separately.
