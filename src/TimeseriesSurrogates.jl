module TimeseriesSurrogates

# TODO: I think it is more clear when each file uses the packages it needs instead of
# the global usage here. It makes it easier to understand how each algorithm works
# and what it needs
using Distributions
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
include("methods/wiaaft.jl")
include("methods/tfts.jl")
include("methods/pseudoperiodic.jl")

# TODO: I think its more clear when each file exports the names it defines.
# The Julia function Base.names() can give you all exported names, so no reason to
# group them at the source.

# Visualization routine for time series + surrogate + periodogram/acf/histogram
using Requires
function __init__()
    @require Plots="91a5bcdd-55d7-5caf-9e0b-520d859cae80" begin
        # Define and export plot routines for all combinations of example processes and surrogate
        # types
        processes = (:AR1, :NSAR2, :randomwalk, :SNLST)
        surrogate_methods = (:RandomShuffle, :BlockShuffle, :RandomFourier, :AAFT, :IAAFT, :TFTS, :PseudoPeriodic)
        include("plotting/surrogate_plot.jl")
        include("plotting/plots_and_anim.jl")
    end

    @require UncertainData="dcd9ba68-c27b-5cea-ae21-829cd07325bf" begin
        include("utils/uncertaindatasets.jl")
    end
end

end # module
