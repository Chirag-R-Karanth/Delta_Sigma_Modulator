function sim = simulate_mash(x, stages)
%SIMULATE_MASH Behavioral cascaded first-order 1-bit MASH model.
% x must be normalized to [0,1), and stages must be 2 or 3.
% Each stage receives the previous stage's quantizer residue.
% Cancellation: y = q1 + D*q2 (+ D^2*q3), D = 1 - z^-1.

    validateattributes(x, {'numeric'}, {'vector','real','finite'});
    validateattributes(stages, {'numeric'}, {'scalar','integer','>=',2,'<=',3});
    x = x(:).';
    if any(x < 0) || any(x >= 1)
        error('Input samples must lie in [0,1).');
    end

    N = numel(x);
    q = zeros(stages, N);
    residue = zeros(stages, N);
    state = zeros(stages, 1);

    for n = 1:N
        stage_input = x(n);
        for k = 1:stages
            v = stage_input + state(k);
            q(k,n) = floor(v);
            residue(k,n) = v - q(k,n);
            state(k) = residue(k,n);
            stage_input = residue(k,n);
        end
    end

    % Apply causal finite differences to downstream stage bitstreams.
    y = q(1,:);
    if stages >= 2
        y = y + filter([1 -1], 1, q(2,:));
    end
    if stages >= 3
        y = y + filter([1 -2 1], 1, q(3,:));
    end

    sim.input = x;
    sim.stage_output = q;
    sim.stage_residue = residue;
    sim.output = y;
    sim.error = y - x;
    sim.stages = stages;
end
