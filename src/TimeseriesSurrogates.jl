module TimeseriesSurrogates

# Use the README as the module docs
@doc let
    path = joinpath(dirname(@__DIR__), "README.md")
    include_dependency(path)
    read(path, String)
end TimeseriesSurrogates

using Random
using Distributions
using Distances # Will be used by the LombScargle method
using AbstractFFTs
using DSP
using Interpolations
using Wavelets
using StateSpaceSets
export standardize

include("core/api.jl")
include("core/surrogate_test.jl")

include("utils/testsystems.jl")
include("plotting/surrogate_plot.jl")

# The different surrogate routines
include("methods/randomshuffle.jl")
include("methods/large_shuffle.jl")
include("methods/randomfourier.jl")
include("methods/aaft.jl")
include("methods/iaaft.jl")
include("methods/truncated_fourier.jl")
include("methods/partial_randomization.jl")
include("methods/wavelet_based.jl")
include("methods/pseudoperiodic.jl")
include("methods/pseudoperiodic_twin.jl")
include("methods/multidimensional.jl")
include("methods/ar.jl")
include("methods/trend_based.jl")

# Methods for irregular time series
include("methods/lombscargle.jl")


end # module
