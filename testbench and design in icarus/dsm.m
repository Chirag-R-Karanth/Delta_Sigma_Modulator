
clc;
clear;
close all;

%% PARAMETERS

W = 16;
MOD = 2^W;
NSAMPLES = 65536;

FCW_LIST = [hex2dec('4000'), ...
            hex2dec('8000'), ...
            hex2dec('C000')];

NINT = 100;

%% TEST EACH FRACTION

for test = 1:length(FCW_LIST)

    FCW = FCW_LIST(test);

    fraction = FCW/MOD;

    fprintf('\n================================\n');
    fprintf('TEST %d\n',test);
    fprintf('FCW = %04X\n',FCW);
    fprintf('Requested fraction = %.9f\n',fraction);

    %% FIRST ORDER

    acc1 = 0;

    first_out = zeros(1,NSAMPLES);

    for k = 1:NSAMPLES

        temp = acc1 + FCW;

        carry = floor(temp/MOD);

        acc1 = mod(temp,MOD);

        first_out(k) = carry;

    end

    %% MASH 1-1

    acc1 = 0;
    acc2 = 0;

    carry2_prev = 0;

    mash_out = zeros(1,NSAMPLES);

    for k = 1:NSAMPLES

        % Stage 1
        temp1 = acc1 + FCW;

        carry1 = floor(temp1/MOD);

        acc1 = mod(temp1,MOD);

        % Stage 2
        temp2 = acc2 + acc1;

        carry2 = floor(temp2/MOD);

        acc2 = mod(temp2,MOD);

        % Error cancellation
        mash_out(k) = carry1 + carry2 - carry2_prev;

        carry2_prev = carry2;

    end

    %% NUMERICAL VERIFICATION

    first_avg = mean(first_out);
    mash_avg = mean(mash_out);

    first_error = first_avg - fraction;
    mash_error = mash_avg - fraction;

    fprintf('\nFIRST ORDER\n');

    fprintf('Average = %.9f\n',first_avg);
    fprintf('Error = %.12f\n',first_error);

    fprintf('\nMASH 1-1\n');

    fprintf('Average = %.9f\n',mash_avg);
    fprintf('Error = %.12f\n',mash_error);

    %% FREQUENCY COMMAND

    fprintf('\nAVERAGE DIVIDER COMMAND\n');

    fprintf('First order = %.9f\n', ...
        NINT + first_avg);

    fprintf('MASH 1-1 = %.9f\n', ...
        NINT + mash_avg);

    %% TIME DOMAIN PLOTS

    figure('Name',sprintf('Fraction %.4f',fraction));

    subplot(2,1,1);

    stairs(first_out(1:200));

    grid on;

    title(sprintf('First Order DDSM - Fraction %.4f',fraction));

    xlabel('Clock Cycle');

    ylabel('Output');

    subplot(2,1,2);

    stairs(mash_out(1:200));

    grid on;

    title('MASH 1-1 Output');

    xlabel('Clock Cycle');

    ylabel('Signed Output');

    %% FFT / PSD

    x1 = first_out - mean(first_out);

    x2 = mash_out - mean(mash_out);

    % Hann window
    w = 0.5 - 0.5*cos(2*pi*(0:NSAMPLES-1)/(NSAMPLES-1));

    X1 = fft(x1.*w);

    X2 = fft(x2.*w);

    PSD1 = abs(X1).^2;

    PSD2 = abs(X2).^2;

    f = (0:NSAMPLES/2-1)/NSAMPLES;

    figure('Name','DDSM PSD');

    plot(f,10*log10(PSD1(1:NSAMPLES/2)+eps), ...
        'b');

    hold on;

    plot(f,10*log10(PSD2(1:NSAMPLES/2)+eps), ...
        'r');

    grid on;

    xlabel('Normalized Frequency');

    ylabel('Relative Power (dB)');

    title(sprintf('DDSM Spectrum - Fraction %.4f',fraction));

    legend('First Order','MASH 1-1');

end

fprintf('\nALL TESTS COMPLETED\n');
