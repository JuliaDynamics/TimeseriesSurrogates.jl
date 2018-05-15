module TimeseriesSurrogates

# package code goes here
using Distributions
using StatsBase
using InplaceOps
using DSP
using Interpolations
using Wavelets

include("interpolation.jl")
include("randomshuffle.jl")
include("randomphases.jl")
include("randomamplitudes.jl")
include("aaft.jl")
include("iaaft.jl")
include("wiaaft.jl")

export intp,
    randomshuffle,
    randomphases,
    aaft,
    iaaft

end # module
