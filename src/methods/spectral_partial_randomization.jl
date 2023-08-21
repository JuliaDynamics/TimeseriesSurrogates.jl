export SpectralPartialRandomization, SpectralPartialRandomizationAAFT

"""
    SpectralSpectralPartialRandomization(α = 0.1)
`SpectralPartialRandomization` surrogates are similar to [`PartialRandomization`](@ref)
phase surrogates, but instead of drawing phases uniformly from `[0, 2π]`, phases of the
highest frequency components responsible for a proportion `α` of power are replaced by
random phases drawn from `[0, 2π]`

See the documentation for a detailed comparison between partial randomization algorithms.
"""
struct SpectralPartialRandomization{T} <: Surrogate
    α::T

    function SpectralPartialRandomization(α::T=0.1) where T <: Real
        @assert 0 <= α <= 1
        return new{T}(α)
    end
end

function surrogenerator(x::AbstractVector, rf::SpectralPartialRandomization, rng = Random.default_rng())
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

    S = r.^2
    S = S ./ sum(S[2:end]) # Ignore power due to the mean, S[1]
    fthresh = findfirst(cumsum(S) .> 1 - rf.α)
    isnothing(fthresh) && (fthresh = n+1)

    init = (; inverse, m, coeffs, n, r, ϕ, shuffled𝓕, fthresh)
    return SurrogateGenerator(rf, x, s, init, rng)
end

function (sg::SurrogateGenerator{<:SpectralPartialRandomization})()
    inverse, m, coeffs, n, r, ϕ, shuffled𝓕, fthresh =
        getfield.(Ref(sg.init),
        (:inverse, :m, :coeffs, :n, :r, :ϕ, :shuffled𝓕, :fthresh))
    s, rng = sg.s, sg.rng

    coeffs .= rand(rng, Uniform(0, 2π), n)
    coeffs[1:fthresh-1] .= 0
    coeffs .= (ϕ .+ coeffs)

    shuffled𝓕 .= r .* cis.(coeffs)
    s .= inverse * shuffled𝓕 .+ m
    return s
end

"""
    SpectralPartialRandomizationAAFT(α = 0.5)

`SpectralPartialRandomizationAAFT` surrogates are similar to
[`PartialRandomization`](@ref) surrogates, but add a rescaling step, so that the
surrogate has the same values as the original time series (analogous to the rescaling done for [`AAFT`](@ref) surrogates).
"""
struct SpectralPartialRandomizationAAFT{T} <: Surrogate
    α::T

    function SpectralPartialRandomizationAAFT(α::T=0.1) where T <: Real
        @assert 0 <= α <= 1
        return new{T}(α)
    end
end

function surrogenerator(x::AbstractVector, rf::SpectralPartialRandomizationAAFT, rng = Random.default_rng())
    init = (
        gen = surrogenerator(x, SpectralPartialRandomization(rf.α), rng),
        ix = zeros(Int, length(x)),
        x_sorted = sort(x),
    )
    s = similar(x)
    return SurrogateGenerator(rf, x, s, init, rng)
end

function (sg::SurrogateGenerator{<:SpectralPartialRandomizationAAFT})()
    gen, ix, x_sorted = sg.init.gen, sg.init.ix, sg.init.x_sorted
    s = sg.s

    # Surrogate starts out as a SpectralPartialRandomization surrogate
    s .= gen()

    # Rescale to obtain a AAFT-like surrogate
    sortperm!(ix, s)
    s[ix] .= x_sorted

    return s
end
