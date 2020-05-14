export TFTS
"""   
    TFTS(fϵ::Real)

A truncated Fourier transform surrogate[^Nakamura2006].

The null hypothesis that these surrogate test is that a stationary linear 
system generated the irregular fluctuations in the signal[^Nakamura2006].

[^Nakamura2006]: Nakamura, Tomomichi, Michael Small, and Yoshito Hirata. "Testing for nonlinearity in irregular fluctuations with long-term trends." Physical Review E 74.2 (2006): 026205.
"""
struct TFTS <: Surrogate
    M::Int
    tol::Real
    W::Int
    fϵ # ratio of high-frequency domain to the whole domain

    function TFTS(fϵ::Real; M::Int = 100, tol::Real = 1e-6, W::Int = 75)
        new(M, tol, W, fϵ)
    end
end

function surrogenerator(x, method::TFTS)
    # Pre-plan Fourier transforms
    forward = plan_rfft(x)
    inverse = plan_irfft(forward*x, length(x))
    
    # Pre-compute 𝓕
    𝓕 = forward*x

    # Polar coordinate representation of the Fourier transform
    rx = abs.(𝓕)
    ϕx = angle.(𝓕)
    n = length(𝓕)
    
    x_sorted = sort(x)

    # These are updated during iteration procedure
    𝓕new = Vector{Complex{Float64}}(undef, length(𝓕))
    𝓕s = Vector{Complex{Float64}}(undef, length(𝓕))
    ϕs = Vector{Complex{Float64}}(undef, length(𝓕))

    init = (forward = forward, inverse = inverse, 
        rx = rx, ϕx = ϕx, n = n, 
        x_sorted = x_sorted,
        𝓕new = 𝓕new, 𝓕s = 𝓕s, ϕs = ϕs)

    return SurrogateGenerator(method, x, init)
end

function (sg::SurrogateGenerator{<:TFTS})()
    x = sg.x 
    fϵ = sg.method.fϵ
    L = length(x)

    init_fields = (:forward, :inverse, 
        :rx, :ϕx, :n, 
        :x_sorted, 
        :𝓕new, :𝓕s, :ϕs)

    forward, inverse, 
        rx, ϕx, n, 
        x_sorted, 
        𝓕new, 𝓕s, ϕs = getfield.(Ref(sg.init), init_fields)

    # Surrogate starts out as a random permutation of x
    s = x[StatsBase.sample(1:L, L, replace = false)]
    𝓕s .= forward*s
    ϕs .= angle.(𝓕s)

    # fϵ is the ratio of high-frequency domain to the whole domain.
    # e.g. when phases with frequency between 1500 and 2000, fϵ = 1500/2000 = 0.25
    # so fϵ = Nhifreq/Nlofreq
    
    # Updated spectrum is the old amplitudes with the mixed phases.
    if fϵ >= 0 # lowest frequencies are kept
        n_hi = ceil(Int, abs(fϵ * n))
        ϕs[1:n_hi] .= ϕx[1:n_hi]
    else # highest frequencies are kept
        n_lo = ceil(Int, abs(fϵ * n))
        ϕs[end-n_lo:end] .= ϕx[end-n_lo:end]
    end

    𝓕new .= rx .* exp.(ϕs .* 1im)

    s .= inverse*𝓕new

    # Rescale amplitudes according to original time series
    s[sortperm(s)] .= x_sorted
    return s
end