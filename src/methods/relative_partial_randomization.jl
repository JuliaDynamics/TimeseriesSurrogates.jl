export RelativePartialRandomization, RelativePartialRandomizationAAFT

"""
    RelativePartialRandomization(α = 0.5)

`RelativePartialRandomization` surrogates are similar to [`PartialRandomization`](@ref)
phase surrogates, but instead of drawing phases uniformly from `[0, 2π]`, phases are drawn
from `ϕ + [0, 2π]*α`, where `α ∈ [0, 1]` and `ϕ` is the original Fourier phase.

See the documentation for a detailed comparison between partial randomization algorithms.
"""
struct RelativePartialRandomization{T} <: Surrogate
    α::T

    function RelativePartialRandomization(α::T=0.5) where T <: Real
        0 <= α <= 1 || throw(ArgumentError("α must be between 0 and 1"))
        return new{T}(α)
    end
end

function surrogenerator(x::AbstractVector, rf::RelativePartialRandomization, rng = Random.default_rng())
    forward = plan_rfft(x)
    inverse = plan_irfft(forward*x, length(x))
    m = mean(x)
    𝓕 = forward*(x .- m)
    shuffled𝓕 = zero(𝓕)
    s = similar(x)
    n = length(𝓕)
    r = abs.(𝓕)
    ϕ = angle.(𝓕)
    coeffs = zero(r)

    init = (; inverse, m, coeffs, n, r, ϕ, shuffled𝓕)
    return SurrogateGenerator(rf, x, s, init, rng)
end

function (sg::SurrogateGenerator{<:RelativePartialRandomization})()
    inverse, m, coeffs, n, r, ϕ, shuffled𝓕 =
        getfield.(Ref(sg.init),
        (:inverse, :m, :coeffs, :n, :r, :ϕ, :shuffled𝓕))
    s, rng = sg.s, sg.rng
    α = sg.method.α

    coeffs .= rand(rng, Uniform(0, 2π), n)
    coeffs .= (ϕ .+ coeffs.*α)
    shuffled𝓕 .= r .* cis.(coeffs)
    s .= inverse * shuffled𝓕 .+ m
    return s
end

"""
    RelativePartialRandomizationAAFT(α = 0.5)

`RelativePartialRandomizationAAFT` surrogates are similar to
[`RelativePartialRandomization`](@ref) surrogates, but add a rescaling step, so that the
surrogate has the same values as the original time series (analogous to the rescaling done
for [`AAFT`](@ref) surrogates).
"""
struct RelativePartialRandomizationAAFT{T} <: Surrogate
    α::T

    function RelativePartialRandomizationAAFT(α::T=0.5) where T <: Real
        0 <= α <= 1 || throw(ArgumentError("α must be between 0 and 1"))
        return new{T}(α)
    end
end

function surrogenerator(x::AbstractVector, rf::RelativePartialRandomizationAAFT, rng = Random.default_rng())
    init = (
        gen = surrogenerator(x, RelativePartialRandomization(rf.α), rng),
        ix = zeros(Int, length(x)),
        x_sorted = sort(x),
    )
    s = similar(x)
    return SurrogateGenerator(rf, x, s, init, rng)
end

function (sg::SurrogateGenerator{<:RelativePartialRandomizationAAFT})()
    gen, ix, x_sorted = sg.init.gen, sg.init.ix, sg.init.x_sorted
    s = sg.s

    # Surrogate starts out as a RelativePartialRandomization surrogate
    s .= gen()

    # Rescale to obtain a AAFT-like surrogate
    sortperm!(ix, s)
    s[ix] .= x_sorted

    return s
end
