export ShuffleDimensions

"""
    ShuffleDimensions()
Multidimensional surrogates of input *datasets* (`DelayEmbeddings.Dataset`, which are
also multidimensional) that have shuffled dimensions in each point.

These surrogates destroy the state space structure of the dataset and are thus
suited to distinguish deterministic datasets from high dimensional noise.
"""
struct ShuffleDimensions <: Surrogate end

function surrogenerator(x, sd::ShuffleDimensions)
    @assert isa Dataset "input `x` must be `DelayEmbeddings.Dataset` for `ShuffleDimensions`"
    return SurrogateGenerator(sd, x, nothing)
end

function (rf::SurrogateGenerator{<:ShuffleDimensions})()
    # actually do the shuffling
end
