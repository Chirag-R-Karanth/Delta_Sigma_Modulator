# MASH 1-1 vs MASH 1-1-1 — MATLAB study

This folder adds a MATLAB-only simulation and graphical comparison of second- and third-order cascaded MASH modulators. Existing repository files are retained.

## Requirements
- MATLAB R2019b or newer (`tiledlayout` is used).
- No Communications Toolbox, DSP System Toolbox, or Symbolic Math Toolbox required.

## Run
From the repository root in MATLAB:

```matlab
cd MATLAB
verify_model
run_comparison
```

Figures and CSV summaries are written to `MATLAB/results/`.

## Model and conventions
Each stage is a first-order, 1-bit error-feedback accumulator with a normalized input in [0,1):
`v[n] = u[n] + s[n-1]`, `q[n] = floor(v[n])`, `s[n] = v[n]-q[n]`.
The residue `s[n]` is fed to the next stage.

With `D(z)=1-z^{-1}`, the stage relation is `Q_i = U_i - D S_i`. Therefore the cancellation combinations are:

- MASH 1-1: `Y = Q1 + D Q2 = Q1 + Q2 - z^-1 Q2`.
- MASH 1-1-1: `Y = Q1 + D Q2 + D^2 Q3`.

Substitution gives the idealized NTFs `-D^2` and `-D^3` respectively (the minus sign does not affect magnitude or PSD). The existing MASH 1-1 expression in `testbench and design in icarus/dsm.m` already uses the correct plus-derivative cancellation convention. Its sign is not wrong; the new MATLAB model retains that convention.

## Experiments
The runner performs:
1. DC tests at 0.25, 0.50 and 0.75.
2. A sinusoid centered at 0.5 with amplitude 0.2.
3. Time-domain output and error plots.
4. Output/error PSDs and ideal NTF magnitude responses.
5. Tone-excluded in-band noise power and SNR estimates.
6. An OSR sweep for the sinusoidal test.
7. Mean-output checks and a CSV summary.

## Interpretation cautions
This is a behavioral, floating-point accumulator model, not a bit-accurate fixed-width RTL model. The ideal NTF assumes linearized quantization noise and exact cancellation. The deterministic 1-bit quantizer can produce idle tones/limit cycles, especially for DC inputs. Treat the PSD as a deterministic sequence spectrum, not proof that quantization error is white. The reported in-band noise integrates output-spectrum bins inside the signal band after excluding the fundamental and adjacent bins; harmonic distortion remains counted as noise. SNR is the fundamental-bin power divided by that residual in-band power.
