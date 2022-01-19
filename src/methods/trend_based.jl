

export TFTDRandomFourier
"""
    TFTDRandomFourier()

The `TFTDRandomFourier` surrogate was proposed by Lucio et al. (2012)[^Lucio2012] as 
a combination of truncated Fourier surrogates[^Nakamura2006] ([`TFTS`](@ref)) and 
detrend-retrend surrogates.

The `TFTD` part of the name comes from the fact that it uses a combination of truncated 
Fourier transforms (TFT) and de-trending and re-trending (D) the time series 
before and after surrogate generation. Hence, it can be used to generate surrogates also from 
(strongly) nonstationary time series. 

## Implementation details

Here, a best-fit linear trend is removed/added from the signal prior to and after generating 
the random Fourier signal. In principle, any trend can be removed, but so far, we only provide
the linear option.

[^Nakamura2006]: Nakamura, Tomomichi, Michael Small, and Yoshito Hirata. "Testing for nonlinearity in irregular fluctuations with long-term trends." Physical Review E 74.2 (2006): 026205.
[^Lucio2012]: Lucio, J. H., Valdés, R., & Rodríguez, L. R. (2012). Improvements to surrogate data methods for nonstationary time series. Physical Review E, 85(5), 056202.
"""
struct TFTDRandomFourier <: Surrogate
    phases::Bool
    fϵ

    function TFTDRandomFourier(phases::Bool, fϵ = 0.05)
        if !(0 < fϵ ≤ 1)
            throw(ArgumentError("`fϵ` must be on the interval  (0, 1] (indicates fraction of lowest frequencies to be preserved)"))
        end
        new(phases, fϵ)
    end
end

const TFTD = TFTDRandomFourier

# Efficient linear regression formula from dmbates julia discourse post (nov 2019)
# https://discourse.julialang.org/t/efficient-way-of-doing-linear-regression/31232/27?page=2
function linreg(x::AbstractVector{T}, y::AbstractVector{T}) where {T<:AbstractFloat}
    (N = length(x)) == length(y) || throw(DimensionMismatch())
    ldiv!(cholesky!(Symmetric([T(N) sum(x); zero(T) sum(abs2, x)], :U)), [sum(y), dot(x, y)])
end

function linear_trend(x)
    l = linreg(0.0:1.0:length(x)-1.0 |> collect, x)
    trendᵢ(xᵢ) = l[1] + l[2] * xᵢ
    return trendᵢ.(x)
end

function surrogenerator(x::AbstractVector, rf::TFTDRandomFourier, rng = Random.default_rng())
    # Detrended time series
    m = mean(x)
    trend = linear_trend(x)

    x̂ = x .- m .- trend

    # Pre-plan Fourier transforms
    forward = plan_rfft(x̂)
    inverse = plan_irfft(forward * x̂, length(x̂))
 
    # Pre-compute 𝓕
    𝓕 = forward*x̂
 
    # Polar coordinate representation of the Fourier transform
    rx = abs.(𝓕)
    ϕx = angle.(𝓕)
    n = length(𝓕)
  
    # These are updated during iteration procedure
    𝓕new = Vector{Complex{Float64}}(undef, length(𝓕))
    𝓕s = Vector{Complex{Float64}}(undef, length(𝓕))
    ϕs = Vector{Complex{Float64}}(undef, length(𝓕))
 
    init = (forward = forward, inverse = inverse,
        rx = rx, ϕx = ϕx, n = n, m = m,
        𝓕new = 𝓕new, 𝓕s = 𝓕s, ϕs = ϕs, 
        trend = trend, x̂ = x̂)

    return SurrogateGenerator(rf, x, init, rng)
end

function (sg::SurrogateGenerator{<:TFTDRandomFourier})()
    fϵ = sg.method.fϵ

    init_fields = (:forward, :inverse,
        :rx, :ϕx, :n, :m,
        :𝓕new, :𝓕s, :ϕs, :trend, :x̂)

    forward, inverse,
        rx, ϕx, n, m,
        𝓕new, 𝓕s, ϕs, trend, x̂ = getfield.(Ref(sg.init), init_fields)

    # Surrogate starts out as a random permutation of x̂
    s = x̂[StatsBase.sample(sg.rng, 1:length(x̂), length(x̂); replace = false)]
    𝓕s .= forward*s
    ϕs .= angle.(𝓕s)

    # Frequencies are ordered from lowest when taking the Fourier
    # transform, so by keeping the 1:n_preserve first phases intact,
    # we are only randomizing the high-frequency components of the
    # signal.
    n_preserve = ceil(Int, abs(fϵ * n))
    ϕs[1:n_preserve] .= ϕx[1:n_preserve]
    
    # Updated spectrum is the old amplitudes with the mixed phases.
    𝓕new .= rx .* exp.(ϕs .* 1im)

    return inverse*𝓕new .+ m .+ trend
end
