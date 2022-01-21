export TFTS, TAAFT

"""
    TFTS(fϵ::Real)

A truncated Fourier transform surrogate[^Nakamura2006] (TFTS).

TFTS surrogates are generated by leaving some frequencies untouched when performing the
phase shuffling step (as opposed to randomizing all frequencies, like for
[`RandomFourier`](@ref) surrogates).

These surrogates were designed to deal with data with irregular fluctuations superimposed
over long term trends (by preserving low frequencies)[^Nakamura2006]. Hence, TFTS surrogates
can be used to test the null hypothesis that the signal is a stationary linear system
generated the irregular fluctuations part of the signal[^Nakamura2006].

## Controlling the truncation of the spectrum

The truncation parameter `fϵ ∈ [-1, 0) ∪ (0, 1]` controls which parts of the spectrum are preserved.

- If `fϵ > 0`, then `fϵ` indicates the ratio of high frequency domain to the entire frequency domain.
    For example, `fϵ = 0.5` preserves 50% of the frequency domain (randomizing the higher
    frequencies, leaving low frequencies intact).
- If `fϵ < 0`, then `fϵ` indicates ratio of low frequency domain to the entire frequency domain.
    For example, `fϵ = -0.2` preserves 20% of the frequency domain (leaving higher frequencies intact,
    randomizing the lower frequencies).
- If `fϵ ± 1`, then all frequencies are randomized. The method is then equivalent to
    [`RandomFourier`](@ref).

The appropriate value of `fϵ` strongly depends on the data and time series length, and must be
manually determined[^Nakamura2006], for example by comparing periodograms for the time series and
the surrogates.

[^Nakamura2006]: Nakamura, Tomomichi, Michael Small, and Yoshito Hirata. "Testing for nonlinearity in irregular fluctuations with long-term trends." Physical Review E 74.2 (2006): 026205.
"""
struct TFTS <: Surrogate
    fϵ::Real

    function TFTS(fϵ::Real)
        if !(0 < fϵ ≤ 1) && !(-1 ≤ fϵ < 0)
            throw(ArgumentError("`fϵ` must be on the interval [-1, 0) ∪ (0, 1] (positive if preserving high frequencies, negative if preserving low frequencies)"))
        end
        new(fϵ)
    end
end

function surrogenerator(x, method::TFTS, rng = Random.default_rng())
    # Pre-plan Fourier transforms
    forward = plan_rfft(x)
    inverse = plan_irfft(forward*x, length(x))

    # Pre-compute 𝓕
    𝓕 = forward * x

    # Polar coordinate representation of the Fourier transform
    rx = abs.(𝓕)
    ϕx = angle.(𝓕)
    n = length(𝓕)

    # These are updated during iteration procedure
    𝓕new = Vector{Complex{Float64}}(undef, length(𝓕))
    𝓕s = Vector{Complex{Float64}}(undef, length(𝓕))
    ϕs = Vector{Complex{Float64}}(undef, length(𝓕))

    init = (forward = forward, inverse = inverse,
        rx = rx, ϕx = ϕx, n = n,
        𝓕new = 𝓕new, 𝓕s = 𝓕s, ϕs = ϕs)

    return SurrogateGenerator(method, x, similar(x), init, rng)
end

function (sg::SurrogateGenerator{<:TFTS})()
    x, s = sg.x, sg.s
    fϵ = sg.method.fϵ
    L = length(x)

    init_fields = (:forward, :inverse,
        :rx, :ϕx, :n,
        :𝓕new, :𝓕s, :ϕs)

    forward, inverse,
        rx, ϕx, n,
        𝓕new, 𝓕s, ϕs = getfield.(Ref(sg.init), init_fields)

    # Surrogate starts out as a random permutation of x
    s .= x[StatsBase.sample(sg.rng, 1:L, L; replace = false)]
    𝓕s .= forward * s
    ϕs .= angle.(𝓕s)

    # Updated spectrum is the old amplitudes with the mixed phases.
    if fϵ > 0
        # Frequencies are ordered from lowest when taking the Fourier
        # transform, so by keeping the 1:n_ni first phases intact,
        # we are only randomizing the high-frequency components of the
        # signal.
        n_preserve = ceil(Int, abs(fϵ * n))
        ϕs[1:n_preserve] .= ϕx[1:n_preserve]
    elseif fϵ < 0
        # Do the exact opposite to preserve high-frequencies
        n_preserve = ceil(Int, abs(fϵ * n))
        ϕs[end-n_preserve+1:end] .= ϕx[end-n_preserve+1:end]
    end

    𝓕new .= rx .* exp.(ϕs .* 1im)
    s .= inverse * 𝓕new
    
    return s
end

"""
    TAAFT(fϵ)

An truncated version of the amplitude-adjusted-fourier-transform surrogate[^Theiler1991][^Nakamura2006].

The truncation parameter and phase randomization procedure is identical to [`TFTS`](@ref), but here an
additional step of rescaling back to the original data is performed. This preserves the
amplitude distribution of the original data.

[^Theiler1991]: J. Theiler, S. Eubank, A. Longtin, B. Galdrikian, J. Farmer, Testing for nonlinearity in time series: The method of surrogate data, Physica D 58 (1–4) (1992) 77–94.
[^Nakamura2006]: Nakamura, Tomomichi, Michael Small, and Yoshito Hirata. "Testing for nonlinearity in irregular fluctuations with long-term trends." Physical Review E 74.2 (2006): 026205.
"""
struct TAAFT <: Surrogate
    fϵ::Real

    function TAAFT(fϵ::Real)
        fϵ != 0 || throw(ArgumentError("`fϵ` must be on the interval [-1, 0) ∪ (0, 1] (positive if preserving high frequencies, negative if preserving low frequencies)"))
        new(fϵ)
    end
end

function surrogenerator(x, method::TAAFT, rng = Random.default_rng())
    init = (
        gen = surrogenerator(x, TFTS(method.fϵ), rng),
        x_sorted = sort(x),
    )
    
    s = similar(x)
    return SurrogateGenerator(method, x, s, init, rng)
end

function (taaft::SurrogateGenerator{<:TAAFT})()
    sg = taaft.init.gen
    x_sorted = taaft.init.x_sorted
    
    x, s = sg.x, sg.s
    fϵ = sg.method.fϵ
    L = length(x)

    init_fields = (:forward, :inverse,
        :rx, :ϕx, :n,
        :𝓕new, :𝓕s, :ϕs)

    forward, inverse,
        rx, ϕx, n,
        𝓕new, 𝓕s, ϕs = getfield.(Ref(sg.init), init_fields)

    # Surrogate starts out as a random permutation of x
    s .= x[StatsBase.sample(sg.rng, 1:L, L; replace = false)]
    𝓕s .= forward * s
    ϕs .= angle.(𝓕s)

    # Updated spectrum is the old amplitudes with the mixed phases.
    if fϵ > 0
        # Frequencies are ordered from lowest when taking the Fourier
        # transform, so by keeping the 1:n_ni first phases intact,
        # we are only randomizing the high-frequency components of the
        # signal.
        n_preserve = ceil(Int, abs(fϵ * n))
        #println("Preserving $(n_preserve/n*100) % of the frequencies (randomizing high frequencies)")
        ϕs[1:n_preserve] .= ϕx[1:n_preserve]
    elseif fϵ < 0
        # Do the exact opposite to preserve high-frequencies
        n_preserve = ceil(Int, abs(fϵ * n))
        #println("Preserving $(n_preserve/n*100) % of the frequencies (randomizing low frequencies)")
        ϕs[end-n_preserve+1:end] .= ϕx[end-n_preserve+1:end]
    end

    𝓕new .= rx .* exp.(ϕs .* 1im)
    s .= inverse * 𝓕new
    
    s = sg()
    s[sortperm(s)] .= x_sorted
    return s
end


