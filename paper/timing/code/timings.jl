# Activate the current directory and load packages.
using Pkg;
Pkg.activate(@__DIR__)
using DelimitedFiles, TimeseriesSurrogates, BenchmarkTools, Plots, Distributions, 
    DynamicalSystems, Random, StatsPlots;

# Use GR backend for plotting.
gr()

x = readdlm("$(@__DIR__)/timeseries.csv")[:, 1]

# Reproducibility (note: this is not possible using Lancaster et al.'s MATLAB code.)
rng = Random.MersenneTwister(1234);

# Pre-initialize all different surrogate types
# ------------------------------------------

# Shuffle based surrogates
rs = surrogenerator(x, RandomShuffle(), rng)
rp = surrogenerator(x, RandomFourier(true), rng)
aaft = surrogenerator(x, AAFT(), rng)
iaaft = surrogenerator(x, IAAFT(), rng)

# Pseudoperiodic surrogates (PPS). Here, as in "timings.m", we use a subset of 500 time 
# series points.
x_pps = x[1:1000]
τ = estimate_delay(x_pps, "ac_min")
d = findmin(delay_fnn(x_pps, τ))[2]
ρ = noiseradius(x_pps, d, τ, 0.025:0.025:0.5)
pps = surrogenerator(x_pps, PseudoPeriodic(d, τ, ρ, true))

# Collect surrogate generators and run once to trigger precompilation
surrogens = [rs, rp, aaft, iaaft, pps];
surrogates = [s() for s in surrogens];

# Define labels for plot.
methods = ["RandomShuffle()", "RandomFourier(true)", "AAFT()", "IAAFT()", "PseudoPeriodic()"];
n_methods = length(methods)

function generate_surrs(surrogenerator, n)
    for i = 1:n
        surrogenerator()
    end
end

"""
    time_n(methods; n = 100)

Compute `n` surrogates using each pre-initialized `Surrogenerator` in `methods` and compute the 
mean time to generate a surrogate.
"""
function time_n(methods; n = 100)
    benchmarks = zeros(length(methods))
    for (i, surrogen) in enumerate(methods)
        benchmarks[i] = @belapsed generate_surrs($surrogen, $n)
    end
    
    return benchmarks ./ n
end
time_n(surrogens, n = 1);

# Like in `timings.m`, compute average time to generate surrogate over 500 
# realizations of each surrogate type
timings = time_n(surrogens, n = 500); 

# Import the timings we generated using the `timings.m` MATLAB script.
# The ordering in that file is [rp, ft, aaft, iaaft, pps];
matlab_timings = readdlm("$(@__DIR__)/matlab_timings.csv")[:, 1]


# Plot the results
x = repeat(methods, outer = 2)
gp = repeat(["TimeseriesSurrogates.jl", "MATLAB"], inner = 5)
c = repeat(["Black", "Red"], inner = 5)

groupedbar(
    [timings matlab_timings],
    group = gp, 
    c = c,
    xrotation = 45,
    ylabel = "Mean runtime (s)",
    yaxis = :log10, 
    yticks = [10.0^(i) for i = -6:0.5:-1],
    ylims = (10^-6, 10^-1),
    xticks = (1:5, ["rp", "ft", "aaft", "iaaft", "pps"]),
    legend = :topleft,
)

savefig("$(@__DIR__)/../../figs/timings.png")