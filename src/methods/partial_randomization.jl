export PartialRandomization, PartialRandomizationAAFT

"""
    PartialRandomization(α = 0.5)
`PartialRandomization` surrogates[^Ortega1998] are similar to [`RandomFourier`](@ref) phase 
surrogates, but during the phase randomization step, instead of drawing phases from `[0, 2π]`,
phases are drawn from `[0, 2π]*α`, where `α ∈ [0, 1]`. The authors refers to `α` as the 
"degree" of phase randomization, where `α = 0` means `0 %` randomization and 
`α = 1` means `100 %` randomization.

[^Ortega1998]: Ortega, Guillermo J.; Louis, Enrique (1998). Smoothness Implies Determinism in Time Series: A Measure Based Approach. Physical Review Letters, 81(20), 4345–4348. doi:10.1103/PhysRevLett.81.4345
"""
struct PartialRandomization{T} <: Surrogate
    α::T

    function PartialRandomization(α::T) where T <: Real 
        @assert 0 <= α <= 1
        return new{T}(α)
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
    
    init = (inverse = inverse, m = m, coeffs = coeffs, n = n, r = r, 
            ϕ = ϕ, shuffled𝓕 = shuffled𝓕)
    return SurrogateGenerator(rf, x, s, init, rng)
end

function (sg::SurrogateGenerator{<:PartialRandomization})()
    inverse, m, coeffs, n, r, ϕ, shuffled𝓕 = 
        getfield.(Ref(sg.init), 
        (:inverse, :m, :coeffs, :n, :r, :ϕ, :shuffled𝓕))
    s, rng = sg.s, sg.rng
    α = sg.method.α

    coeffs .= rand(rng, Uniform(0, 2π), n)
    shuffled𝓕 .= r .* exp.(coeffs .* 1im .* α)
    s .= inverse * shuffled𝓕 .+ m
    return s
end

"""
    PartialRandomizationAAFT(α = 0.5)

`PartialRandomizationAAFF` surrogates are similar to [`PartialRandomization`](@ref) 
surrogates[^Ortega1998], but adds a rescaling step, so that the surrogate has 
the same values as the original time series (analogous to the rescaling done for
[`AAFT`](@ref) surrogates).
Partial randomization surrogates have, to the package authors' knowledge, not been 
published in scientific literature.

[^Ortega1998]: Ortega, Guillermo J.; Louis, Enrique (1998). Smoothness Implies Determinism in Time Series: A Measure Based Approach. Physical Review Letters, 81(20), 4345–4348. doi:10.1103/PhysRevLett.81.4345
"""
struct PartialRandomizationAAFT{T} <: Surrogate
    α::T

    function PartialRandomizationAAFT(α::T) where T <: Real 
        @assert 0 <= α <= 1
        return new{T}(α)
    end
end

function surrogenerator(x::AbstractVector, rf::PartialRandomizationAAFT, rng = Random.default_rng())
    init = (
        gen = surrogenerator(x, PartialRandomization(rf.α), rng),
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