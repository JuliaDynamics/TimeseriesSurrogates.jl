export AAFT

"""
    AAFT()

An amplitude-adjusted-fourier-transform (AAFT) surrogate[^Theiler1991].

AAFT surrogates have the same linear correlation, or periodogram, and also
preserves the amplitude distribution of the original data.

AAFT surrogates can be used to test the null hypothesis that the data come from a
monotonic nonlinear transformation of a linear Gaussian process
(also called integrated white noise)[^Theiler1991].

[^Theiler1991]: J. Theiler, S. Eubank, A. Longtin, B. Galdrikian, J. Farmer, Testing for nonlinearity in time series: The method of surrogate data, Physica D 58 (1–4) (1992) 77–94.
"""
struct AAFT <: Surrogate end

function surrogenerator(x, method::AAFT, rng = Random.default_rng())
    n = length(x)
    m = mean(x)
    forward = plan_rfft(x)
    inverse = plan_irfft(forward * x, n)
    𝓕 = forward * (x .- m)

    init = (
        x_sorted = sort(x),
        ix = zeros(Int, n),
        inverse = inverse,
        m = m,
        𝓕 = 𝓕,
        r = abs.(𝓕),
        ϕ = angle.(𝓕),
        shuffled𝓕 = similar(𝓕),
        coeffs = zero(𝓕),
        n = n,
    )

    return SurrogateGenerator(method, x, similar(x), init, rng)
end

function (sg::SurrogateGenerator{<:AAFT})()
    s, rng = sg.s, sg.rng

    init_fields = (:x_sorted, :ix, :inverse, :m, :r, :ϕ, :shuffled𝓕, :coeffs, :n)
        x_sorted, ix,  inverse, m, r, ϕ, shuffled𝓕, coeffs, n = 
        getfield.(Ref(sg.init), init_fields)

    coeffs .= rand(rng, Uniform(0, 2π), length(shuffled𝓕))
    shuffled𝓕 .= r .* exp.(coeffs .* 1im)
    s .= (inverse * shuffled𝓕) .+ m

    # Rescale back to original values to obtain AAFT surrogate.
    sortperm!(ix, s)
    s[ix] .= x_sorted
    
    return s
end
