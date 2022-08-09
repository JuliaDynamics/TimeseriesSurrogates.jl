data = readtable("data.csv");
x = data{:, 1};
n = 100;

tic
surrogate(x, nsurr, 'RP', 0, 1);
t_rp = toc / nsurr;

tic
surrogate(x, nsurr, 'FT', 0, 1);
t_ft = toc / nsurr;

tic
surrogate(x, nsurr, 'AAFT', 0, 1);
t_aaft = toc / nsurr;

tic
surrogate(x, nsurr, 'IAAFT2', 0, 1);
t_iaaft = toc / nsurr;

tic
% Use a subset of the time series for the PPS method (it is slow)
x_pps = x(1:1000);
surrogate(x_pps, nsurr, 'PPS', 0, 1);
t_pps = toc / nsurr;

% Save MATLAB timings for import in Julia script.
matlab_times = [t_rp, t_ft, t_aaft, t_iaaft, t_pps];
writematrix(matlab_times.', './matlab_timings.csv')
