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
    @assert x isa Dataset "input `x` must be `DelayEmbeddings.Dataset` for `ShuffleDimensions`"
    return SurrogateGenerator(sd, x, nothing, rng)
end

function (sg::SurrogateGenerator{<:ShuffleDimensions})()
    data = copy(sg.x.data)
    for i in 1:length(data)
        @inbounds data[i] = shuffle(sg.rng, data[i])
    end
    return Dataset(data)
end

export ShuffleDimensions2
struct ShuffleDimensions2 <: Surrogate end

function surrogenerator(x, sd::ShuffleDimensions2, rng = Random.default_rng())
    s = copy(x.data)
    @assert x isa Dataset "input `x` must be `DelayEmbeddings.Dataset` for `ShuffleDimensions`"
    return SurrogateGenerator2(sd, x, s, nothing, rng)
end

function (sg::SurrogateGenerator2{<:ShuffleDimensions2})()
    s = sg.s
    for i in 1:length(s)
        @inbounds s[i] = shuffle(sg.rng, s[i])
    end
    return Dataset(s)
end

