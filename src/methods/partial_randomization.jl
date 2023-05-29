export PartialRandomization, PartialRandomizationAAFT

"""
    PartialRandomization(α = 0.5, alg = :absolute)
`PartialRandomization` surrogates[^Ortega1998] are similar to [`RandomFourier`](@ref)
phase surrogates, but during the phase randomization step, instead of drawing phases
uniformly from `[0, 2π]`, phases are drawn from a constrained set of random values. We provide three algorithms for partially randomizing the Fourier phases, which can be chosen from using the second, `alg`, argument:
- `:absolute`   Random phases are drawn from `[0, 2π]*α`, where `α ∈ [0, 1]`[^Ortega1998].
- `:relative`   Random phases are drawn from `ϕ + [0, 2π]*α`, where `α ∈ [0, 1]` and `ϕ`
                is the original Fourier phase.
- `:spectrum`   Phases of the highest frequency components responsible for a proportion `α`
                of power are replaced by random phases drawn from `[0, 2π]`

See the documentation for a detailed comparison of the three algorithms.

[^Ortega1998]: Ortega, Guillermo J.; Louis, Enrique (1998). Smoothness Implies Determinism in Time Series: A Measure Based Approach. Physical Review Letters, 81(20), 4345–4348. doi:10.1103/PhysRevLett.81.4345
"""
struct PartialRandomization{T} <: Surrogate
    α::T
    alg::Symbol

    function PartialRandomization(α::T=0.5, alg::Symbol=:absolute) where T <: Real
        @assert 0 <= α <= 1
        @assert alg ∈ [:absolute, :relative, :spectrum]
        return new{T}(α, alg)
    end
end

function surrogenerator(x::AbstractVector, rf::PartialRandomization, rng = Random.default_rng())
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

    fthresh = nothing
    if rf.alg == :spectrum
        S = r.^2
        S = S ./ sum(S[2:end]) # Ignore power due to the mean, S[1]
        fthresh = findfirst(cumsum(S) .> 1 - rf.α)
    end
    isnothing(fthresh) && (fthresh = n+1)

    init = (; inverse, m, coeffs, n, r, ϕ, shuffled𝓕, fthresh)
    return SurrogateGenerator(rf, x, s, init, rng)
end

function (sg::SurrogateGenerator{<:PartialRandomization})()
    inverse, m, coeffs, n, r, ϕ, shuffled𝓕, fthresh =
        getfield.(Ref(sg.init),
        (:inverse, :m, :coeffs, :n, :r, :ϕ, :shuffled𝓕, :fthresh))
    s, rng = sg.s, sg.rng
    α = sg.method.α
    alg = sg.method.alg

    coeffs .= rand(rng, Uniform(0, 2π), n)

    if alg === :absolute
        coeffs .= (coeffs.*α)
    elseif alg === :relative
        coeffs .= (ϕ .+ coeffs.*α)
    elseif alg === :spectrum
        coeffs[1:fthresh-1] .= 0
        coeffs .= (ϕ .+ coeffs)
    end

    shuffled𝓕 .= r .* cis.(coeffs)
    s .= inverse * shuffled𝓕 .+ m
    return s
end

"""
    PartialRandomizationAAFT(α = 0.5, alg = :absolute)

`PartialRandomizationAAFT` surrogates are similar to [`PartialRandomization`](@ref) surrogates, but adds a rescaling step, so that the surrogate has
the same values as the original time series (analogous to the rescaling done for
[`AAFT`](@ref) surrogates).
Partial randomization surrogates with a rescaling step have, to the package authors'
knowledge, not been published in scientific literature.
"""
struct PartialRandomizationAAFT{T} <: Surrogate
    α::T
    alg::Symbol

    function PartialRandomizationAAFT(α::T, alg::Symbol=:absolute) where T <: Real
        @assert 0 <= α <= 1
        @assert alg ∈ [:absolute, :relative, :spectrum]
        return new{T}(α, alg)
    end
end

function surrogenerator(x::AbstractVector, rf::PartialRandomizationAAFT, rng = Random.default_rng())
    init = (
        gen = surrogenerator(x, PartialRandomization(rf.α, rf.alg), rng),
        ix = zeros(Int, length(x)),
        x_sorted = sort(x),
    )
    s = similar(x)
    return SurrogateGenerator(rf, x, s, init, rng)
end

function (sg::SurrogateGenerator{<:PartialRandomizationAAFT})()
    gen, ix, x_sorted = sg.init.gen, sg.init.ix, sg.init.x_sorted
    s = sg.s

    # Surrogate starts out as a PartialRandomization surrogate
    s .= gen()

    # Rescale to obtain a AAFT-like surrogate
    sortperm!(ix, s)
    s[ix] .= x_sorted

    return s
end
