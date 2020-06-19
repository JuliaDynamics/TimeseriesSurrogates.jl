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

function surrogenerator(x, sd::ShuffleDimensions)
    @assert x isa Dataset "input `x` must be `DelayEmbeddings.Dataset` for `ShuffleDimensions`"
    return SurrogateGenerator(sd, x, nothing)
end

function (sg::SurrogateGenerator{<:ShuffleDimensions})()
    data = copy(sg.x.data)
    for i in 1:length(data)
        data[i] = shuffle(data[i])
    end
    return Dataset(data)
end
