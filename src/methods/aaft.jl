export AAFT

"""
    AAFT()

An amplitude-adjusted-fourier-transform surrogate[^Theiler1991].

AAFT have the same linear correlation, or periodogram, and also
preserves the amplitude distribution of the original data.

AAFT can be used to test the null hypothesis that the data come from a
monotonic nonlinear transformation of a linear Gaussian process
(also called integrated white noise)[^Theiler1991].

[^Theiler1991]: J. Theiler, S. Eubank, A. Longtin, B. Galdrikian, J. Farmer, Testing for nonlinearity in time series: The method of surrogate data, Physica D 58 (1–4) (1992) 77–94.
"""
struct AAFT <: Surrogate end

function surrogenerator(x, method::AAFT, rng = Random.default_rng())
    n = length(x)

    # Forward Fourier transform plan
    forward = plan_rfft(x)

    m = mean(x)

    𝓕 = forward * (x .- m)

    init = (
        # A sorted version of `x`. Used when rescaling back to original values.
        x_sorted = sort(x),

        # A vector that holds permutation indices
        ix = zeros(Int, n),
        
        # Inverse Fourier transform plan
        inverse = plan_irfft(forward * x, n),

        # Mean of `x`
        m = m,

        # Forward transform on mean-subtracted data
        𝓕 = 𝓕,

        # The following variables are pre-computed here, so we don't re-allocate 
        # when calling the surrogate generator.
        # ----------------------------------------------------------------------
        r = abs.(𝓕),

        # Phases  (compute here, so we don't allocate when generating)
        ϕ = angle.(𝓕),

        # Holds the new transform (after shuffling phases/amplitudes)
        shuffled𝓕 = similar(𝓕),

        # Randomized coefficients,
        coeffs = zero(𝓕),

        n = n,
    )

    return SurrogateGenerator(method, x, similar(x), init, rng)
end

function (sg::SurrogateGenerator{<:AAFT})()
    # Initialization data
    s, rng = sg.s, sg.rng

    init_fields = (:x_sorted, :ix, :inverse, :m, :r, :ϕ, :shuffled𝓕, :coeffs, :n)
        x_sorted, ix,  inverse, m, r, ϕ, shuffled𝓕, coeffs, n = 
        getfield.(Ref(sg.init), init_fields)

    # A Fourier surrogate is the starting point for the AAFT surrogate. Generate 
    # one such surrogate and assign it to `sg.s`.
    
    # `coeffs` := randomized phases
    coeffs .= rand(rng, Uniform(0, 2π), length(shuffled𝓕))

    # Updated Fourier transform, with shuffled phases
    shuffled𝓕 .= r .* exp.(coeffs .* 1im)
    
    # Inverse Fourier transform
    s .= (inverse * shuffled𝓕) .+ m

    # The indices that would sort the random Fourier phase surrogate
    sortperm!(ix, s)

    # Rescale back to original values to obtain AAFT surrogate.
    s[ix] .= x_sorted
    
    return s
end
