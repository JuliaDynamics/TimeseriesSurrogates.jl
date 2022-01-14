data = readtable("data.csv");
x = data{:, 1};
n = 100;

tic
surrogate(x, n, 'RP', 0, 1);
t_rp = toc / n;

tic
surrogate(x, n, 'FT', 0, 1);
t_ft = toc / n;

tic
surrogate(x, n, 'AAFT', 0, 1);
t_aaft = toc / n;

tic
surrogate(x, n, 'IAAFT2', 0, 1);
t_iaaft = toc / n;
% 
% tic
% surrogate(x, n, 'PPS', 0, 1);
% t_pps = toc / n;

t_julia_rp = 0.00017723043333333334;
t_julia_aaft = 0.0006152220666666667;
t_julia_iaaft = 0.014016834433333332;
t_julia_pps = 0.4744213161333333;

frac_rp = t_julia_rp / t_rp;
frac_aaft = t_julia_aaft / t_aaft;
frac_iaaft = t_julia_iaaft / t_iaaft;
frac_pps = t_julia_pps / t_pps;

timings = [frac_rp, frac_aaft, frac_iaaft, frac_pps];

