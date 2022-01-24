using LinearAlgebra
export TFTDRandomFourier, TFTD, TFTDAAFT, TFTDIAAFT

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
    TFTD(phases::Bool = true, fϵ = 0.05)

The `TFTDRandomFourier` (or just `TFTD` for short) surrogate was proposed by Lucio et al. (2012)[^Lucio2012] as 
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

See also: [`TFTDAAFT`](@ref), [`TFTDIAAFT`](@ref).

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
TFTD() = TFTD(true)
TFTD(fϵ::Real) = TFTD(true, fϵ)

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

    # Compute forward transform and get its phases
    mul!(𝓕, forward, s) # 𝓕 .= forward * s is equivalent, but allocates
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

"""
    TFTDAAFT(fϵ = 0.05)

[`TFTDAAFT`](@ref)[^Lucio2012] are similar to [`TFTD`](@ref) surrogates, but also re-scales 
back to the original values of the time series. `fϵ ∈ (0, 1]` is the fraction of the powerspectrum 
corresponding to the lowermost frequencies to be preserved.

See also: [`TFTD`](@ref), [`TFTDIAAFT`](@ref).

[^Lucio2012]: Lucio, J. H., Valdés, R., & Rodríguez, L. R. (2012). Improvements to surrogate data methods for nonstationary time series. Physical Review E, 85(5), 056202.
"""
struct TFTDAAFT <: Surrogate
    fϵ

    function TFTDAAFT(fϵ = 0.05)
        if !(0 < fϵ ≤ 1)
            throw(ArgumentError("`fϵ` must be on the interval  (0, 1] (indicates fraction of lowest frequencies to be preserved)"))
        end
        new(fϵ)
    end
end

function surrogenerator(x::AbstractVector, method::TFTDAAFT, rng = Random.default_rng())    
    init = (
        gen = surrogenerator(x, TFTS(method.fϵ), rng),
        ix = zeros(Int, length(x)),
        x_sorted = sort(x),
    )
    s = similar(x)

    return SurrogateGenerator(method, x, s, init, rng)
end

function (sg::SurrogateGenerator{<:TFTDAAFT})()
    s = sg.s
    tfts_gen, ix, x_sorted = sg.init.gen, sg.init.ix, sg.init.x_sorted
    s .= tfts_gen()
    sortperm!(ix, s)
    s[ix] .= x_sorted

    return s
end

"""
    TFTDIAAFT(fϵ = 0.05; M::Int = 100, tol::Real = 1e-6, W::Int = 75)

[`TFTDIAAFT`](@ref)[^Lucio2012] are similar to [`TFTDAAFT`](@ref), but adds an iterative 
procedure to better match the periodograms of the surrogate and the original time series, 
analogously to how [`IAAFT`](@ref) improves upon [`AAFT`](@ref). 

`fϵ ∈ (0, 1]` is the fraction of the powerspectrum corresponding to the lowermost 
frequencies to be preserved. `M` is the maximum number of iterations. `tol` is the 
desired maximum relative tolerance between power spectra. `W` is the number of 
bins into which the periodograms are binned when comparing across iterations.

See also: [`TFTD`](@ref), [`TFTDAAFT`](@ref).

[^Lucio2012]: Lucio, J. H., Valdés, R., & Rodríguez, L. R. (2012). Improvements to surrogate data methods for nonstationary time series. Physical Review E, 85(5), 056202.
"""
struct TFTDIAAFT <: Surrogate
    fϵ
    M::Int
    tol::Real
    W::Int

    function TFTDIAAFT(fϵ = 0.05; M::Int = 100, tol::Real = 1e-6, W::Int = 75)
        if !(0 < fϵ ≤ 1)
            throw(ArgumentError("`fϵ` must be on the interval  (0, 1] (indicates fraction of lowest frequencies to be preserved)"))
        end
        new(fϵ, M, tol, W)
    end
end

function surrogenerator(x::AbstractVector, method::TFTDIAAFT, rng = Random.default_rng())
    # Surrogate starts out as a TFTDRandomFourier surrogate
    gen = surrogenerator(x, TFTDRandomFourier(true, method.fϵ), rng)

    # Pre-allocate forward transform for periodogram; can be re-used.
    𝓕, x̂, forward = gen.init.𝓕, gen.init.x̂, gen.init.forward
    𝓕p = prepare_spectrum(x̂, forward)

    # Initial power spectra and their interpolated versions.
    xpower = zeros(length(𝓕)); 
    powerspectrum!(𝓕p, xpower, x̂, forward)
    spower = copy(xpower)
    xpowerᵦ = interpolated_spectrum(xpower, method.W)
    spowerᵦ = interpolated_spectrum(spower, method.W)

    init = (
        gen = gen,
        ix = zeros(Int, length(x)),
        x_sorted = sort(x),
        𝓕p = 𝓕p,
        xpower = xpower, 
        spower = spower,
        xpowerᵦ = xpowerᵦ,
        spowerᵦ = spowerᵦ,
    )

    s = similar(x)
    return SurrogateGenerator(method, x, s, init, rng)
end

function (sg::SurrogateGenerator{<:TFTDIAAFT})()
    x, s, rng = sg.x, sg.s, sg.rng
    fϵ, M, W, tol = sg.method.fϵ, sg.method.M, sg.method.W, sg.method.tol
    n_preserve = ceil(Int, abs(fϵ * length(x)))

    tftd_gen = sg.init.gen
    𝓕, forward, ϕs, ϕx, rx, trend, x̂ = getfield.(Ref(tftd_gen.init), 
        (:𝓕, :forward, :ϕx, :ϕs, :rx, :trend, :x̂)
    )
    x_sorted, ix, 𝓕p, xpower, spower, xpowerᵦ, spowerᵦ = getfield.(Ref(sg.init), 
        (:x_sorted, :ix, :𝓕p, :xpower, :spower, :xpowerᵦ, :spowerᵦ)
    )

    sum_old, sum_new = 0.0, 0.0
    iter = 1

    # Surrogate starts out as a TFTDRandomFourier realization of `x`.
    s .= tftd_gen()

    while iter <= M
        # Detrend and take transform (steps (vii-viii) in Lucio et al.)
        s .= s .- trend
        mul!(𝓕, forward, s)

        # Rescaling the power spectrum, keeping some percentage of lowermost 
        # frequencies, then re-trending (steps vii-x in Lucio et al.)
        ϕs .= angle.(𝓕)
        ϕs[1:n_preserve] .= @view ϕx[1:n_preserve]
        𝓕 .= rx .* exp.(ϕs .* 1im)
        s .= s .+ trend
        
        # Adjusting amplitudes
        sortperm!(ix, s)
        s[ix] .= x_sorted

        # Compare power spectra
        powerspectrum!(𝓕p, spower, s, forward)
        interpolated_spectrum!(spowerᵦ, spower, W)
        if iter == 1
            sum_old = sum((xpowerᵦ .- xpowerᵦ) .^ 2) / sum(xpowerᵦ .^ 2)
        else 
            sum_new = sum((xpowerᵦ .- spowerᵦ) .^ 2) / sum(xpowerᵦ .^ 2)
            if abs(sum_old - sum_new) < tol
                iter = M + 1
            else
                sum_old = sum_new
            end
        end

        iter += 1
    end

    return s
end
