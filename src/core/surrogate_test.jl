using Random: AbstractRNG
import StatsAPI
export SurrogateTest, StatsAPI.pvalue

"""
    SurrogateTest(f::Function, x, method::Surrogate; kwargs...)

Initialize a surrogate test for input data `x`, which can be used in [`pvalue`](@ref).
The tests requires as input a function `f` that given a timeseries (like `x`) it
outputs a real number, and a method of how to generate surrogates.
`f` is the function that computes the discriminatory statistic.

Once called with [`pvalue`](@ref), the test stores the real value `rval` and surrogate
values `vals` of the discriminatory statistic in the fields `rval, vals` respectively.

`SurrogateTest` automates the process described in the documentation page
[Performing surrogate hypothesis tests](@ref).

`SurrogateTest` subtypes `HypothesisTest` and is part of the StatsAPI.jl interface.

## Keywords

- `rng = Random.default_rng()`: a random number generator.
- `n::Int = 10_000`: how many surrogates to generate and compute `f` on.
"""
struct SurrogateTest{F<:Function, S<:SurrogateGenerator, X<:Real} <: StatsAPI.HypothesisTest
    f::F
    sgen::S
    # fields that are filled whenever a function is called
    # for pretty printing or for keeping track of results
    rval::X
    vals::Vector{X}
    isfilled::Base.RefValue{Bool}
end

# Pretty printing
function Base.show(io::IO, ::MIME"text/plain", test::SurrogateTest)
    descriptors = [
        "discr. statistic" => nameof(test.f),
        "surrogate method" => nameof(typeof(test.sgen.method)),
        "input timeseries" => summary(test.sgen.x),
        "# of surrogates" => length(test.vals),
    ]

    padlen = maximum(length(d[1]) for d in descriptors) + 3

    print(io, "SurrogateTest")
    for (desc, val) in descriptors
        print(io, '\n', rpad(" $(desc): ", padlen), val)
    end
    return
end

function SurrogateTest(f::F, x, s::Surrogate;
        rng = Random.default_rng(), n = 10_000
    ) where {F<:Function}
    sgen = surrogenerator(x, s, rng)
    rval = f(x)
    X = typeof(rval)
    vals = zeros(X, n)
    return SurrogateTest{F, typeof(sgen), X}(f, sgen, rval, vals, Ref(false))
end

function fill_surrogate_test!(test::SurrogateTest)
    test.isfilled[] && return
    # TODO: Threading here.
    for i in eachindex(test.vals)
        test.vals[i] = test.f(test.sgen())
    end
    test.isfilled[] = true
    return
end

"""
    pvalue(test::SurrogateTest; tail = :left)

Return the [p-value](https://en.wikipedia.org/wiki/P-value) corresponding to the given
[`SurrogateTest`](@ref), optionally specifying what kind of tail test to do
(one of `:left, :right, :both`).

The default value of `tail` assumes that the surrogate data are expected to have higher
discriminatory statistic values. This is the case for statistics that quantify entropy.
For statistics that quantify autocorrelation, use `tail = :right` instead.

`pvalue` comes from StatsAPI.jl.
"""
function StatsAPI.pvalue(test::SurrogateTest; tail = :left)
    fill_surrogate_test!(test)
    (; rval, vals) = test
    if tail == :right
        p = count(v -> v ≥ rval, vals)
    elseif tail == :left
        p = count(v -> v ≤ rval, vals)
    else
        pr = count(v -> v ≥ rval, vals)
        pl = count(v -> v ≤ rval, vals)
        p = 2min(pr, pl)
    end
    return p/length(vals)
end
