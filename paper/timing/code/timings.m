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

tic
surrogate(x, n, 'PPS', 0, 1);
t_pps = toc / n;


[t_rp, t_ft, t_aaft, t_iaaft, t_pps];

