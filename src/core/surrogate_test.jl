using Random: AbstractRNG
import StatsAPI: HypothesisTest, pvalue
export SurrogateTest, pvalue, fill_surrogate_test!
using Base.Threads

"""
    SurrogateTest(f::Function, x, method::Surrogate; kwargs...) → test

Initialize a surrogate test for input data `x`, which can be used in [`pvalue`](@ref).
The tests requires as input a function `f` that given a timeseries (like `x`) it
outputs a real number, and a method of how to generate surrogates.
`f` is the function that computes the discriminatory statistic.

Once called with [`pvalue`](@ref), the `test` estimates and then
stores the real value `rval` and surrogate
values `vals` of the discriminatory statistic in the fields `rval, vals` respectively.
Alternatively, you can use [`fill_surrogate_test!`](@ref) directly if you don't care about
the p-value.

`SurrogateTest` automates the process described in the documentation page
[Performing surrogate hypothesis tests](@ref).

`SurrogateTest` subtypes `HypothesisTest` and is part of the StatsAPI.jl interface.

## Keywords

- `rng = Random.default_rng()`: a random number generator.
- `n::Int = 10_000`: how many surrogates to generate and compute `f` on.
- `threaded = true`: Whether to parallelize looping over surrogate computations in
   to the available threads (`Threads.nthreads()`).
"""
struct SurrogateTest{F<:Function, S<:SurrogateGenerator, X<:Real} <: HypothesisTest
    f::F
    sgens::Vector{S}
    # fields that are filled whenever a function is called
    # for pretty printing or for keeping track of results
    rval::X
    vals::Vector{X}
    threaded::Bool
end


function SurrogateTest(f::F, x, s::Surrogate;
        rng = Random.default_rng(), n = 10_000, threaded = true
    ) where {F<:Function}

    if threaded
        seeds = rand(rng, 1:typemax(Int), Threads.nthreads())
        sgens = [surrogenerator(x, s, Random.Xoshiro(seed)) for seed in seeds]
    else
        sgens = [surrogenerator(x, s, rng)]
    end
    rval = f(x)
    X = typeof(rval)
    vals = zeros(X, n)
    return SurrogateTest{F, typeof(first(sgens)), X}(f, sgens, rval, vals, threaded)
end

# Pretty printing
function Base.show(io::IO, ::MIME"text/plain", test::SurrogateTest)
    descriptors = [
        "discr. statistic" => nameof(test.f),
        "surrogate method" => nameof(typeof(first(test.sgens).method)),
        "input timeseries" => summary(test.sgens[1].x),
        "# of surrogates" => length(test.vals),
    ]

    padlen = maximum(length(d[1]) for d in descriptors) + 3

    print(io, "SurrogateTest")
    for (desc, val) in descriptors
        print(io, '\n', rpad(" $(desc): ", padlen), val)
    end
    return
end

"""
    fill_surrogate_test!(test::SurrgateTest) → rval, vals

Perform the computations foreseen by `test` and return
the value of the discriminatory statistic for the real data `rval`
and the distribution of values for the surrogates `vals`.

This function is called by `pvalue`.
"""
function fill_surrogate_test!(test::SurrogateTest)
    if test.threaded
        @inbounds Threads.@threads for i in eachindex(test.vals)
            sgen = test.sgens[Threads.threadid()]
            test.vals[i] = test.f(sgen())
        end
    else
        sgen = first(sgens)
        @inbounds for i in eachindex(test.vals)
            test.vals[i] = test.f(sgen())
        end
    end
    return test.rval, test.vals
end

"""
    pvalue(test::SurrogateTest; tail = :left)

Return the [p-value](https://en.wikipedia.org/wiki/P-value) corresponding to the given
[`SurrogateTest`](@ref), optionally specifying what kind of tail test to do
(one of `:left, :right, :both`).

For [`SurrogateTest`](@ref), the p-value is simply the proportion of surrogate statistics
that exceed (for `tail = :right`) or subseed (`tail = :left`) the discriminatory
statistic computed from the input data.

The default value of `tail` assumes that the surrogate data are expected to have higher
discriminatory statistic values. This is the case for statistics that quantify entropy.
For statistics that quantify autocorrelation, use `tail = :right` instead.
"""
function pvalue(test::SurrogateTest; tail = :left)
    rval, vals = fill_surrogate_test!(test)
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
