module TimeseriesSurrogates
"supertype of all surrogate methods"
abstract type Surrogate end

"""
    surrogate(x, method::Surrogate) → s
Create a surrogate timeseries/signal from input signal `x` and given `method`.
"""
function surrogate end
export Surrogate, surrogate

using Distributions
using StatsBase
using InplaceOps
using AbstractFFTs
using DSP
using Interpolations
using Wavelets
using Requires

# Example systems
include("testsystems.jl")

# Periodogram interpolation
include("interpolation.jl")

include("uncertaindatasets.jl")

# The different surrogate routines
include("randomshuffle.jl")
include("randomphases.jl")
include("randomamplitudes.jl")
include("aaft.jl")
include("iaaft.jl")
include("wiaaft.jl")

export NLNS, NSAR2, AR1, randomwalk, SNLST,
        randomshuffle, randomamplitudes, randomphases, aaft, iaaft, wiaaft

# Visualization routine for time series + surrogate + periodogram/acf/histogram
using Requires
function __init__()
    @require Plots="91a5bcdd-55d7-5caf-9e0b-520d859cae80" begin
        # Define and export plot routines for all combinations of example processes and surrogate
        # types
        processes = (:AR1, :NSAR2, :NLNS, :randomwalk, :SNLST)
        surrogate_methods = (:randomshuffle, :randomphases, :randomamplitudes, :aaft, :iaaft)
        include("surrogate_plot.jl")
        include("plots_and_anim.jl")
    end
end

end # module
