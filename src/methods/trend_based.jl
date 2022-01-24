using LinearAlgebra
export TFTDRandomFourier, TFTD

# Efficient linear regression formula from dmbates julia discourse post (nov 2019)
# https://discourse.julialang.org/t/efficient-way-of-doing-linear-regression/31232/27?page=2
function linreg(x, y)
    (N = length(x)) == length(y) || throw(DimensionMismatch())
    ldiv!(cholesky!(Symmetric([float(N) sum(x); 0.0 sum(abs2, x)], :U)), [sum(y), dot(x, y)])
end

function linear_trend(x)
    l = linreg(0.0:1.0:length(x)-1.0 |> collect, x)
    trendᵢ(xᵢ) = l[1] + l[2] * xᵢ
    return trendᵢ.(x)
end


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

const TFTD2 = TFTDRandomFourier

function surrogenerator(x::AbstractVector, rf::TFTDRandomFourier, rng = Random.default_rng())
    # Detrended time series
    m = mean(x)
    trend = linear_trend(x)
    x̂ = x .- m .- trend

    # Pre-plan and allocate Fourier transform
    forward = plan_rfft(x̂)
    inverse = plan_irfft(forward * x̂, length(x̂))
    𝓕 = forward * x̂
    n = length(𝓕)

    # Polar coordinate representation of the Fourier transform
    rx = abs.(𝓕)
    ϕx = angle.(𝓕)
    ϕs = similar(ϕx)

    permutation = zeros(Int, length(x))
    idxs = collect(1:length(x))
    
    # Initialize surrogate
    s = similar(x)
 
    init = (forward = forward, inverse = inverse,
        rx = rx, ϕx = ϕx, n = n, m = m,
        𝓕 = 𝓕, ϕs = ϕs, 
        trend = trend, x̂ = x̂,
        permutation, idxs)

    return SurrogateGenerator(rf, x, s, init, rng)
end

function (sg::SurrogateGenerator{<:TFTDRandomFourier})()
    fϵ = sg.method.fϵ
    s = sg.s

    init_fields = (:forward, :inverse,
        :rx, :ϕx, :n, :m,
        :𝓕, :ϕs, :trend, :x̂, :permutation, :idxs)

    forward, inverse,
        rx, ϕx, n, m,
        𝓕, ϕs, trend, x̂,
        permutation, idxs = getfield.(Ref(sg.init), init_fields)

    # Surrogate starts out as a random permutation of x̂
    sample!(sg.rng, idxs, permutation; replace = false)
    s .= @view x̂[permutation]

    mul!(𝓕, forward, s)
    ϕs .= angle.(𝓕)

    # Frequencies are ordered from lowest when taking the Fourier
    # transform, so by keeping the 1:n_preserve first phases intact,
    # we are only randomizing the high-frequency components of the
    # signal.
    n_preserve = ceil(Int, abs(fϵ * n))
    ϕs[1:n_preserve] .= @view ϕx[1:n_preserve]
    
    # Updated spectrum is the old amplitudes with the mixed phases.
    𝓕 .= rx .* exp.(ϕs .* 1im)

    # Unfortunately, we can't do inverse transform in-place yet, but 
    # this is an open PR in FFTW.
    s .= inverse*𝓕 .+ m .+ trend

    return s
end
