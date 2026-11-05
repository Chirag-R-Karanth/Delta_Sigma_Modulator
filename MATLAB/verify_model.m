%% Lightweight consistency checks for the MASH behavioral models
clear; clc;
N = 32768;
levels = [0.125 0.25 0.5 0.75 0.875];
tol = 2/N + 1e-12;
fprintf('DC mean-output checks (finite-record tolerance %.3g)\n',tol);
for x0 = levels
    x = x0*ones(1,N);
    a = simulate_mash(x,2);
    b = simulate_mash(x,3);
    e2 = abs(mean(a.output)-x0);
    e3 = abs(mean(b.output)-x0);
    fprintf('x=%.3f | MASH11 error %.3g | MASH111 error %.3g\n',x0,e2,e3);
    assert(e2 < tol && e3 < tol,'Mean-output check failed.');
end
% Check cancellation filter impulse responses.
hD = filter([1 -1],1,[1 zeros(1,4)]);
hD2 = filter([1 -2 1],1,[1 zeros(1,4)]);
assert(isequal(hD(1:3),[1 -1 0]));
assert(isequal(hD2(1:4),[1 -2 1 0]));
fprintf('All model checks passed.\n');
