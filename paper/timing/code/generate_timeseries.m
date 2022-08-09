% Here, we compute the mean time to generate a single surrogate for each of the methods 
% implemented in TimeseriesSurrogates.jl at the time of submission to JOSS. 
% We'll use the same test process as in Lancaster et al, and generate a 5000-pt long
% time series with additive noise from a normal distribution with zero mean and 
% standard deviation 0.3.

% Function to generate the signal
f = @(t) sin(2*pi*(t + 0.5*sin(2*pi * t/10))/3);

% Set random seed
randomseed = rng(1234,'twister');

% Generate a time series
npts = 5000;
t = 1:npts;
x = f(t);


% Add some noise to the time series
noise = normrnd(0, 0.3, size(x));
x = x + noise;

% Save csv for use in Julia.
writematrix(x.', './timeseries.csv');