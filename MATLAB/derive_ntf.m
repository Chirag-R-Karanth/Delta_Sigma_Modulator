%% MASH cancellation derivation using polynomial coefficients
% No Symbolic Math Toolbox is required.
% D(z) = 1 - z^-1.
% Stage relation: Q_i = U_i - D*S_i; U_(i+1) = S_i.
%
% MASH 1-1:
%   Y = Q1 + D*Q2
%     = (X-D*S1) + D*(S1-D*S2)
%     = X-D^2*S2
%
% MASH 1-1-1:
%   Y = Q1 + D*Q2 + D^2*Q3
%     = X-D^3*S3
%
% Thus NTFs are -D^2 and -D^3. The sign does not affect magnitude/PSD.

clear; clc;
fprintf('D(z) = 1 - z^-1\n');
fprintf('MASH 1-1:   NTF = -(1 - z^-1)^2 = -1 + 2z^-1 - z^-2\n');
fprintf('MASH 1-1-1: NTF = -(1 - z^-1)^3 = -1 + 3z^-1 - 3z^-2 + z^-3\n');
fprintf('\nCancellation FIR coefficients (in ascending delay order):\n');
fprintf('D:   [1 -1]\n');
fprintf('D^2: [1 -2 1]\n');
fprintf('D^3: [1 -3 3 -1]\n');
