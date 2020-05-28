module TimeseriesSurrogates

# TODO: I think it is more clear when each file uses the packages it needs instead of
# the global usage here. It makes it easier to understand how each algorithm works
# and what it needs
using Distributions
using Distances # Will be used by the LombScargle method
using StatsBase
using InplaceOps
using AbstractFFTs
using DSP
using Interpolations
using Wavelets
using Requires

include("api.jl")

include("utils/testsystems.jl")

# Periodogram interpolation
include("utils/interpolation.jl")

# The different surrogate routines
include("methods/randomshuffle.jl")
include("methods/blockshuffle.jl")
include("methods/randomfourier.jl")
include("methods/aaft.jl")
include("methods/iaaft.jl")
include("methods/truncated_fourier.jl")
include("methods/wavelet_based.jl")
include("methods/pseudoperiodic.jl")

# Methods for irregular time series
include("methods/lombscargle.jl")

# Visualization routine for time series + surrogate + periodogram/acf/histogram
using Requires
function __init__()
    @require Plots="91a5bcdd-55d7-5caf-9e0b-520d859cae80" begin
        include("plotting/surrogate_plot.jl")
    end
    @require UncertainData="dcd9ba68-c27b-5cea-ae21-829cd07325bf" begin
        include("utils/uncertaindatasets.jl")
    end
end

end # module
