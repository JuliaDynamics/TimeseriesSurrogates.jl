using Pkg; Pkg.activate("./"); Pkg.instantiate();
using TimeseriesSurrogates, BenchmarkTools, Plots, Distributions, DynamicalSystems, Random;
gr()

# Here, we compute the mean time to generate a single surrogate for each of the methods 
# implemented in TimeseriesSurrogates.jl at the time of submission to JOSS. 
# We'll use the same test signal as in Lancaster et al, and generate a 5000-pt long
# time series with additive noise from a normal distribution with zero mean and 
# standard deviation 0.3.
f(t) = sin(2π*(t + 0.5*sin(2π*t/10))/3)
dt = 0.1
npts = 5000
t = 0.0:dt:(npts-1)*dt
ti = sort(t .+ rand(npts))
x = f.(t);

# Add some noise to the signal.
rng = Random.MersenneTwister(1234)
x .+= rand(rng, Normal(0, 0.3), npts); 

# Write to file, to import in matlab
using DelimitedFiles
writedlm("data.csv",  x, ',')

# Pre-initialize all different surrogate types
# Shuffle based surrogates
rs = surrogenerator(x, RandomShuffle(), rng)
rp = surrogenerator(x, RandomFourier(true), rng)
aaft = surrogenerator(x, AAFT(), rng)
iaaft = surrogenerator(x, IAAFT(), rng)

# Pseudoperiodic surrogates (PPS) 
τ = estimate_delay(x, "ac_min")
d = findmin(delay_fnn(x, τ))[2]
ρ = noiseradius(x, d, τ, 0.025:0.025:0.5)
pps = surrogenerator(x, PseudoPeriodic(d, τ, ρ, true))

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

# Compute average time to generate surrogate over 30 realizations of each surrogate type
timings = time_n(surrogens, n = 100); 


# [rp, ft, aaft, iaaft, pps] these were generated in `surrogate.m`
matlab_timings = [2.3975e-04, 1.9309e-04, 5.3265e-04, 0.0140, 0.8464]

# Plot the results
x = repeat(methods, outer = 2)
gp = repeat(["TimeseriesSurrogates.jl", "MATLAB"], inner = 5)
c = repeat(["Black", "Red"], inner = 5)
groupedbar(
    x,
    [timings matlab_timings],
    group = gp,
    c = c,
    xlabel = "Number of surrogates", 
    xrotation = 45,
    ylabel = "Mean runtime (s)",
    yaxis = :log10, 
    xtickfont = font(7),
    ytickfont = font(7),
    guidefont = font(9),
)

savefig("timings.png")