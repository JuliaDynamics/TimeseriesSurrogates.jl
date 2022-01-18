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
struct AAFT2 <: Surrogate end

function surrogenerator(x, method::AAFT2, rng = Random.default_rng())

    # Forward Fourier transform plan
    forward = plan_rfft(x)

    init = (
        # A sorted version of `x`. Used when rescaling back to original values.
        x_sorted = sort(x),

        # A vector that holds permutation indices
        ix = zeros(Int, length(x)),
        
        # Inverse Fourier transform plan
        inverse = plan_irfft(forward*x, length(x)),

        # The following variables are pre-computed here, so we don't re-allocate 
        # when calling the surrogate generator.
        # ----------------------------------------------------------------------
        # Mean of `x`
        m = mean(x),

        # Forward transform on mean-subtracted data
        𝓕 = forward*(x .- m),

        # Amplitudes (compute here, so we don't allocate when generating)
        r = abs.(𝓕),

        # Phases  (compute here, so we don't allocate when generating)
        ϕ = abs.(𝓕),

        # Holds the new transform (after shuffling phases/amplitudes)
        new_𝓕 = similar(𝓕),

        # Randomized coefficients,
        coeffs = zero(x),
    )

    return SurrogateGenerator(method, x, init, rng)
end

function (sg::SurrogateGenerator{<:AAFT2})()
    # Initialization data
    x = sg.x
    rng = sg.rng

    init_fields = (:x_sorted, :ix, :inverse, :m, :𝓕, :r, :ϕ, :new_𝓕, :coeffs)
        x_sorted, ix,  inverse, m, 𝓕, r, ϕ, new_𝓕, coeffs = 
        getfield.(Ref(sg.init), init_fields)

    # A Fourier surrogate is the starting point for the AAFT surrogate. Generate 
    # one such surrogate and assign it to `sg.s`.
    if rf.method.phases
        # Assign randomized phases to `coeffs`
        coeffs .= rand(sg.rng, Uniform(0, 2π), n)

        # Updated Fourier transform, with shuffled phases
        new_𝓕 .= r .* exp.(coeffs .* 1im)
    else
        # Assign randomized amplitudes to `coeffs`
        coeffs .= r .* rand(rf.rng, Uniform(0, 2π), n)

        # Updated Fourier transform, with shuffled amplitudes
        new_𝓕 .= coeffs .* exp.(ϕ .* 1im)
    end
    sg.s .= inverse * new_𝓕 .+ m

    # The indices that would sort the random Fourier phase surrogate
    sortperm!(ix, sg.s)

    # Rescale back to original values to obtain AAFT surrogate.
    sg.s[ix] .= x_sorted
    
    return sg.s
end
