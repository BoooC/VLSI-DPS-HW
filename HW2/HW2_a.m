clear all
close all
clc

%% parameters setting
Iters = 200;            % Iteration Times
M = 15;                 % Filter Size
M_end = M + Iters;      % Final index
W = zeros(M,1);         % Filter Coefficients
W_hist = zeros(M, M_end);% History of Filter Coefficients
mu = 1e-2;              % Step size
n = 1 : M_end;          % Time index
s = sin(2*pi*n/16) + cos(2*pi*n/4); % Input 
d = sin(2*pi*n/16);     % Desired 
e = zeros(M_end);       % Error
r = zeros(M_end);       % RMS 
rms_step = 16;

% Converged Condition
converge_value = 0.05/sqrt(2);
converged = false;

%% LMS Iteration
for i = M : M_end
    U = s(i:-1: i-M+1)';    % Extract input
    d_hat = W' * U;         % Compute filter output
    e(i) = d(i) - d_hat;    % Compute error
    W = W + mu*e(i)*U;      % Update filter coefficients
    W_hist(:,i+1) = W;      % Add coefficients to history
    r(i) = sqrt(mean(e(max(M, i-rms_step+1):i).^2)); % RMS
    % Determine convergence
    if r(i) < converge_value && ~converged
        disp(['Converged at ' num2str(i-M+1) ' iterations.']);
        converged = true;
    end
end

disp(['Min RMS value : ' num2str(min(r(M:Iters)))]);

%% Plot
% Plot the RMS Error versus time
figure('Name','RSM Plot');
plot(M:M_end, r(M:M_end));
xlim([M M_end]);
xlabel('n');
ylabel('RMS Error');
title('RSM versus n');

% Plot the filter coefficients versus time
figure('Name','Filter Coefficients');
plot(M:M_end, W_hist(:, M:M_end)');
xlim([M M_end]);
xlabel('n');
ylabel('Coefficients');
title('Filter Coefficients');

% Compute and plot the frequency response
fft_resp = fft(W, 64);
f = (0:63); % frequency axis
figure('Name','Frequency response');
plot(f, abs(fft_resp));
xlim([0 63]);
xlabel('Sample points(FFT)');
ylabel('Magnitude');
title('64‐point FFT to the impulse response with low pass filter');

%% Determine the minimum M
Iters = 5000;       % Maximum Iteration Times
M_max = 100;     	% Maximum Filter Size
mu = 1e-2;          % Initial Step size
rms_step = 16;

% Converged Condition
converge_value = 0.05/sqrt(2);
convergence_flag = false;

for M = 1:M_max
    M_end = M + Iters;      % Final index
    W = zeros(M,1);         % Filter Coefficients
    n = 1 : M_end;          % Time index
    s = sin(2*pi*n/16) + cos(2*pi*n/4); % Input 
    d = sin(2*pi*n/16);     % Desired 
    e = zeros(M_end, 1);    % Error
    r = zeros(M_end, 1);    % RMS
    
    % LMS Iteration
    for i = M : M_end
        U = s(i:-1: i-M+1)';    % Extract input
        d_hat = W' * U;         % Compute filter output
        e(i) = d(i) - d_hat;    % Compute error
        W = W + mu*e(i)*U;      % Update filter coefficients
        r(i) = sqrt(mean(e(max(M, i-rms_step+1):i).^2)); % RMS
        % Determine convergence
        if r(i) < converge_value
            disp(['Converged at M = ' num2str(M) ', Iteration = ' num2str(i-M+1)]);
            min_M = M;
            min_iter_count = i - M + 1;
            convergence_flag = true;
            break; 
        end
    end
    if convergence_flag
        break; 
    end
end

disp(['Minimum iterations for M converged : ' num2str(min_M)]);
disp(['Iterations required: ' num2str(min_iter_count)]);




