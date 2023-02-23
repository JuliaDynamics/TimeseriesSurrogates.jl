using StateSpaceSets, Random
export ShuffleDimensions

"""
    ShuffleDimensions()

Multidimensional surrogates of input `StateSpaceSet`s.
Each point in the set is individually shuffled.

These surrogates destroy the state space structure of the dataset and are thus
suited to distinguish deterministic datasets from high dimensional noise.
"""
struct ShuffleDimensions <: Surrogate end

function surrogenerator(x, sd::ShuffleDimensions, rng = Random.default_rng())
    if !(x isa AbstractStateSpaceSet)
        error("input `x` must be `AbstractStateSpaceSet` for `ShuffleDimensions`")
    end
    s = copy(x)
    return SurrogateGenerator(sd, x, s, nothing, rng)
end

function (sg::SurrogateGenerator{<:ShuffleDimensions})()
    s = sg.s
    for i in eachindex(s)
        @inbounds s[i] = shuffle(sg.rng, s[i])
    end
    return s
end
