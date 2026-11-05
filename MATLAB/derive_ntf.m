%% Symbolic-by-construction Z-domain MASH cancellation derivation
% Uses D(z)=1-z^-1. For a first-order accumulator:
% Q_i(z) = U_i(z) - D(z) S_i(z), and U_(i+1)=S_i.
% Hence:
% MASH 1-1:   Y = Q1 + D Q2 = X - D^2 S2
% MASH 1-1-1: Y = Q1 + D Q2 + D^2 Q3 = X - D^3 S3
% The NTF signs do not change magnitude or noise PSD.

clear; clc;
syms z
D = 1 - z^(-1);
ntf_mash11 = -D^2;
ntf_mash111 = -D^3;
disp('MASH 1-1 NTF:'); pretty(ntf_mash11)
disp('MASH 1-1-1 NTF:'); pretty(ntf_mash111)
disp('Expanded MASH 1-1 numerator:'); disp(expand((z-1)^2/z^2));
disp('Expanded MASH 1-1-1 numerator:'); disp(expand((z-1)^3/z^3));
