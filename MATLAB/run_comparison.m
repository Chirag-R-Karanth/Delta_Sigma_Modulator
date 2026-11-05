%% MASH 1-1 vs MASH 1-1-1: behavioral simulation and analysis
% Run from this folder. No specialized MATLAB toolboxes are required.
clear; close all; clc;

outDir = fullfile(pwd, 'results');
if ~exist(outDir, 'dir'), mkdir(outDir); end

cfg.fs = 1;                 % normalized sample rate
cfg.N = 65536;              % record length (power of two)
cfg.osr = 64;               % in-band edge = fs/(2*OSR)
cfg.dcLevels = [0.25 0.50 0.75];
cfg.toneBin = 37;            % coherent FFT bin
cfg.toneAmplitude = 0.20;
cfg.toneOffset = 0.50;

n = 0:cfg.N-1;
tone = cfg.toneOffset + cfg.toneAmplitude * ...
       sin(2*pi*cfg.toneBin*n/cfg.N);

summary = {};
row = 0;

%% 1) DC tests: useful for mean accuracy and deterministic idle-tone behavior
for level = cfg.dcLevels
    x = level * ones(1, cfg.N);
    a = simulate_mash(x, 2);
    b = simulate_mash(x, 3);

    figure('Name', sprintf('DC %.2f time/error', level));
    tiledlayout(2,2);
    nexttile; stairs(n(1:300), a.output(1:300)); grid on;
    title(sprintf('MASH 1-1 output, DC %.2f', level)); xlabel('Sample'); ylabel('Output');
    nexttile; stairs(n(1:300), b.output(1:300)); grid on;
    title('MASH 1-1-1 output'); xlabel('Sample'); ylabel('Output');
    nexttile; plot(n(1:300), a.error(1:300)); grid on;
    title('MASH 1-1 instantaneous error'); xlabel('Sample'); ylabel('y-x');
    nexttile; plot(n(1:300), b.error(1:300)); grid on;
    title('MASH 1-1-1 instantaneous error'); xlabel('Sample'); ylabel('y-x');
    saveas(gcf, fullfile(outDir, sprintf('dc_%.2f_time.png', level)));

    fprintf('DC %.2f | mean MASH11 %.9f | mean MASH111 %.9f\n', ...
        level, mean(a.output), mean(b.output));
    row = row + 1;
    summary(row,:) = {sprintf('DC %.2f',level), mean(a.output), mean(b.output), ...
        mean(a.error), mean(b.error), NaN, NaN, NaN, NaN}; %#ok<SAGROW>

    % PSD of the error, with DC removed before spectral estimation.
    [f, pA] = one_sided_psd(a.error - mean(a.error), cfg.fs);
    [~, pB] = one_sided_psd(b.error - mean(b.error), cfg.fs);
    figure('Name', sprintf('DC %.2f error PSD', level));
    plot(f, 10*log10(pA + eps), 'LineWidth', 1); hold on;
    plot(f, 10*log10(pB + eps), 'LineWidth', 1); grid on;
    xlim([0 0.5]); xlabel('Normalized frequency (cycles/sample)');
    ylabel('PSD (dB/sample)'); title(sprintf('Error PSD, DC %.2f',level));
    legend('MASH 1-1','MASH 1-1-1','Location','best');
    saveas(gcf, fullfile(outDir, sprintf('dc_%.2f_error_psd.png', level)));
end

%% 2) Coherent sinusoidal input
a = simulate_mash(tone, 2);
b = simulate_mash(tone, 3);

figure('Name','Sinusoidal time-domain comparison');
tiledlayout(3,1);
nexttile; plot(n(1:500), tone(1:500)); grid on;
title('Input sinusoid'); xlabel('Sample'); ylabel('Input');
nexttile; stairs(n(1:500), a.output(1:500)); grid on;
title('MASH 1-1 output'); xlabel('Sample'); ylabel('Output');
nexttile; stairs(n(1:500), b.output(1:500)); grid on;
title('MASH 1-1-1 output'); xlabel('Sample'); ylabel('Output');
saveas(gcf, fullfile(outDir,'sine_time_domain.png'));

figure('Name','Sinusoidal error comparison');
plot(n(1:500), a.error(1:500)); hold on;
plot(n(1:500), b.error(1:500)); grid on;
xlabel('Sample'); ylabel('Output - input'); title('Instantaneous quantization/reconstruction error');
legend('MASH 1-1','MASH 1-1-1');
saveas(gcf, fullfile(outDir,'sine_error.png'));

[f, pA] = one_sided_psd(a.error, cfg.fs);
[~, pB] = one_sided_psd(b.error, cfg.fs);
figure('Name','Sinusoidal error PSD');
plot(f,10*log10(pA+eps),'LineWidth',1); hold on;
plot(f,10*log10(pB+eps),'LineWidth',1); grid on;
xlim([0 0.5]); xlabel('Normalized frequency (cycles/sample)');
ylabel('PSD (dB/sample)'); title('Error PSD: MASH 1-1 vs MASH 1-1-1');
legend('MASH 1-1','MASH 1-1-1','Location','best');
saveas(gcf,fullfile(outDir,'sine_error_psd.png'));

% Output PSD and tone-excluded in-band SNR.
[~, pyA] = one_sided_psd(a.output - mean(a.output), cfg.fs);
[~, pyB] = one_sided_psd(b.output - mean(b.output), cfg.fs);
figure('Name','Output PSD comparison');
plot(f,10*log10(pyA+eps),'LineWidth',1); hold on;
plot(f,10*log10(pyB+eps),'LineWidth',1); grid on;
xlim([0 0.5]); xlabel('Normalized frequency (cycles/sample)');
ylabel('PSD (dB/sample)'); title('Output PSD: sinusoidal input');
legend('MASH 1-1','MASH 1-1-1','Location','best');
saveas(gcf,fullfile(outDir,'sine_output_psd.png'));

bw = cfg.fs/(2*cfg.osr);
metricsA = inband_metrics(a.output, tone, cfg.fs, bw, cfg.toneBin, cfg.N);
metricsB = inband_metrics(b.output, tone, cfg.fs, bw, cfg.toneBin, cfg.N);
fprintf('\nSINUSOID RESULTS (OSR=%d, in-band edge %.6g fs)\n',cfg.osr,bw/cfg.fs);
fprintf('MASH 1-1:   mean error=%+.4e, tone-excluded in-band noise power=%.4e, SNR=%.2f dB\n', ...
    mean(a.error), metricsA.noisePower, metricsA.snrDb);
fprintf('MASH 1-1-1: mean error=%+.4e, tone-excluded in-band noise power=%.4e, SNR=%.2f dB\n', ...
    mean(b.error), metricsB.noisePower, metricsB.snrDb);
row = row + 1;
summary(row,:) = {'Sinusoid',mean(a.output),mean(b.output),mean(a.error),mean(b.error), ...
    metricsA.noisePower,metricsB.noisePower,metricsA.snrDb,metricsB.snrDb};

%% 3) Theoretical NTF magnitude responses
w = linspace(0,pi,2048);
D = 1 - exp(-1j*w);
ntf2 = abs(D.^2);
ntf3 = abs(D.^3);
figure('Name','Ideal NTF magnitude');
plot(w/pi,20*log10(ntf2+eps),'LineWidth',1.5); hold on;
plot(w/pi,20*log10(ntf3+eps),'LineWidth',1.5); grid on;
xlabel('Frequency / Nyquist'); ylabel('|NTF| (dB)');
title('Idealized NTF magnitude responses');
legend('MASH 1-1: |1-z^{-1}|^2','MASH 1-1-1: |1-z^{-1}|^3','Location','best');
saveas(gcf,fullfile(outDir,'ideal_ntf_magnitude.png'));

figure('Name','NTF zero locations');
z2 = roots([1 -2 1]);
z3 = roots([1 -3 3 -1]);
plot(real(z2),imag(z2),'o','MarkerSize',8,'LineWidth',1.5); hold on;
plot(real(z3),imag(z3),'x','MarkerSize',10,'LineWidth',1.5);
th = linspace(0,2*pi,500); plot(cos(th),sin(th),'k:');
axis equal; grid on; xlabel('Real'); ylabel('Imaginary');
title('NTF zeros (all at z=1)'); legend('MASH 1-1','MASH 1-1-1','Unit circle');
saveas(gcf,fullfile(outDir,'ntf_zeros.png'));

%% 4) OSR sweep: integrate output noise bins inside each signal band
osrList = [8 16 32 64 128];
noise2 = zeros(size(osrList)); noise3 = noise2;
for k = 1:numel(osrList)
    bandEdge = cfg.fs/(2*osrList(k));
    m2 = inband_metrics(a.output, tone, cfg.fs, bandEdge, cfg.toneBin, cfg.N);
    m3 = inband_metrics(b.output, tone, cfg.fs, bandEdge, cfg.toneBin, cfg.N);
    noise2(k) = m2.noisePower;
    noise3(k) = m3.noisePower;
end
figure('Name','In-band noise power vs OSR');
loglog(osrList,noise2,'o-','LineWidth',1.5); hold on;
loglog(osrList,noise3,'s-','LineWidth',1.5); grid on;
xlabel('Oversampling ratio'); ylabel('Integrated tone-excluded in-band noise power');
title('In-band noise power vs OSR (same simulated records)');
legend('MASH 1-1','MASH 1-1-1','Location','best');
saveas(gcf,fullfile(outDir,'inband_noise_vs_osr.png'));

%% 5) Export summary
T = cell2table(summary,'VariableNames',{'Test','MeanOutput_MASH11','MeanOutput_MASH111', ...
    'MeanError_MASH11','MeanError_MASH111','InbandNoisePower_MASH11', ...
    'InbandNoisePower_MASH111','SNR_dB_MASH11','SNR_dB_MASH111'});
writetable(T,fullfile(outDir,'summary.csv'));
disp(T);
fprintf('\nAnalysis complete. Figures and summary saved in: %s\n',outDir);

%% Local analysis functions
function [f,P] = one_sided_psd(x,fs)
    x = x(:);
    N = numel(x);
    win = 0.5 - 0.5*cos(2*pi*(0:N-1)'/(N-1)); % Hann, no toolbox needed
    X = fft(x.*win);
    P2 = abs(X).^2/(fs*sum(win.^2));
    P = P2(1:floor(N/2)+1);
    if numel(P)>2, P(2:end-1) = 2*P(2:end-1); end
    f = (0:floor(N/2))'*fs/N;
end

function m = inband_metrics(y,x,fs,bandEdge,toneBin,N)
    % Rectangular coherent record: exact-bin tone, exclude fundamental bin
    % and its immediate neighbors from noise integration.
    y = y(:); x = x(:);
    Y = fft(y-mean(y));
    P = abs(Y(1:floor(N/2)+1)).^2/N^2;
    f = (0:floor(N/2))'*fs/N;
    inBand = f <= bandEdge;
    toneIdx = toneBin + 1;
    signalBins = max(1,toneIdx-1):min(numel(P),toneIdx+1);
    noiseMask = inBand;
    noiseMask(signalBins) = false;
    m.noisePower = sum(P(noiseMask));
    signalPower = sum(P(signalBins));
    m.snrDb = 10*log10(signalPower/(m.noisePower+eps));
    % Independent time-domain reconstruction-error power in the band is
    % not available by simple scalar variance; PSD of y-x is reported above.
end
