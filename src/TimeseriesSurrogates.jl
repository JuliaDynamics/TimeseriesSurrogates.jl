module TimeseriesSurrogates

using Distributions
using StatsBase
using InplaceOps
using AbstractFFTs
using DSP
using Interpolations
using Wavelets
using Requires
using Plots

# Example systems
include("testsystems.jl")

# Periodogram interpolation
include("interpolation.jl")

# Visualization routine for time series + surrogate + periodogram/acf/histogram
include("surrogate_plot.jl")

# The different surrogate routines
include("randomshuffle.jl")
include("randomphases.jl")
include("randomamplitudes.jl")
include("aaft.jl")
include("iaaft.jl")
include("wiaaft.jl")


# Define and export plot routines for all combinations of example processes and surrogate
# types
processes = (:AR1, :NSAR2, :NLNS, :randomwalk, :SNLST)
surrogate_methods = (:randomshuffle, :randomphases, :randomamplitudes, :aaft, :iaaft)
include("plots_and_anim.jl")

include("uncertaindatasets.jl")

export NLNS, NSAR2, AR1, randomwalk, SNLST,
        randomshuffle, randomamplitudes, randomphases, aaft, iaaft, wiaaft

end # module
