# Instructions

## 1. Run the `timings.m` script in MATLAB

This will:

- Generate a test time series.
- Benchmark the Lancaster et al.'s code on that time series using five different surrogate methods that also exist in TimeseriesSurrogates.jl.
- Export the results as `timeseries.csv` and `matlab_timings.csv`.

## 2. Run the `timings.jl` script in Julia

This will:

- Import the `timeseries.csv` file generated in step 1.
- Benchmark TimeseriesSurrogates.jl on that time series, using the same surrogate methods as for the MATLAB run.
- Generate a bar plot that compares the timings.
- Export the bar plots as a .png file in the "TimeseriesSurrogates.jl/paper/figs/" folder.
