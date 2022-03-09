using DelayEmbeddings, Random
export ShuffleDimensions

"""
    ShuffleDimensions()

Multidimensional surrogates of input *datasets* (`DelayEmbeddings.Dataset`, which are
also multidimensional) that have shuffled dimensions in each point.

These surrogates destroy the state space structure of the dataset and are thus
suited to distinguish deterministic datasets from high dimensional noise.
"""
struct ShuffleDimensions <: Surrogate end

function surrogenerator(x, sd::ShuffleDimensions, rng = Random.default_rng())
    s = copy(x.data)
    @assert x isa Dataset "input `x` must be `DelayEmbeddings.Dataset` for `ShuffleDimensions`"
    return SurrogateGenerator(sd, x, s, nothing, rng)
end

function (sg::SurrogateGenerator{<:ShuffleDimensions})()
    s = sg.s
    for i in 1:length(s)
        @inbounds s[i] = shuffle(sg.rng, s[i])
    end
    return Dataset(s)
end

