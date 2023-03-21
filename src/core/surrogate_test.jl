# import StatsAPI: pvalue
import Random: AbstractRNG
export SurrogateTest, pvalue

abstract type AbstractSurrogateTest end

"""
    SurrogateTest(f::Function, x, method::Surrogate; kwargs...)

Initialize a surrogate test to be used in [`pvalue`](@ref).
The tests requires as input a function `f` that given a timeseries `x` it
outputs a real number, and a method of how to generate surrogates.
`f` is the function that computes the discriminatory statistic.

## Keywords

- `rng = Random.default_rng()`: a random number generator.
- `n::Int = 10_000`: how many surrogates to generate and compute `f` on.
"""
struct SurrogateTest{F<:Function, S<:SurrogateGenerator, X<:Real} <: AbstractSurrogateTest
    f::F
    sgen::S
    n::Int
    # fields that are filled whenever a function is called
    # for pretty printing or for keeping track of results
    rval::X
    vals::Vector{X}
    isfilled::Base.RefValue{Bool}
end

function SurrogateTest(f::F, x, s::Surrogate;
        rng = Random.default_rng(), n = 10_000
    ) where {F<:Function}
    sgen = surrogenerator(x, s, rng)
    rval = f(x)
    X = typeof(rval)
    vals = zeros(X, n)
    return SurrogateTest{F, typeof(sgen), X}(f, sgen, n, rval, vals, Ref(false))
end

function fill_surrogate_test!(test::SurrogateTest)
    test.isfilled[] && return
    # TODO: Threading here.
    for i in 1:test.n
        test.vals[i] = test.f(test.sgen())
    end
    test.isfilled[] = true
    return
end

function pvalue(test::SurrogateTest; tail = :right)
    fill_surrogate_test!(test)
    # estimate pvalue from res.vals
    p = whatever
    return p
end
