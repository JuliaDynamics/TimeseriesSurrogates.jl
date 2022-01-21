export IAAFT


include("../utils/powerspectrum.jl")
include("../utils/interpolation.jl")
export IAAFT

"""
    IAAFT(M = 100, tol = 1e-6, W = 75)

An iteratively adjusted amplitude-adjusted-fourier-transform surrogate[^SchreiberSchmitz1996].

IAAFT surrogate have the same linear correlation, or periodogram, and also
preserves the amplitude distribution of the original data, but are improved relative
to AAFT through iterative adjustment (which runs for a maximum of `M` steps).
During the iterative adjustment, the periodograms of the original signal and the
surrogate are coarse-grained and the powers are averaged over `W` equal-width
frequency bins. The iteration procedure ends when the relative deviation
between the periodograms is less than `tol` (or when `M` is reached).

IAAFT, just as AAFT, can be used to test the null hypothesis that the data 
come from a monotonic nonlinear transformation of a linear Gaussian process.

[^SchreiberSchmitz1996]: T. Schreiber; A. Schmitz (1996). "Improved Surrogate Data for Nonlinearity Tests". [Phys. Rev. Lett. 77 (4)](https://journals.aps.org/prl/abstract/10.1103/PhysRevLett.77.635)
"""
struct IAAFT <: Surrogate
    M::Int
    tol::Real
    W::Int

    function IAAFT(;M::Int = 100, tol::Real = 1e-6, W::Int = 75)
        new(M, tol, W)
    end
end

Base.show(io::IO, x::IAAFT) = print(io, "IAAFT(M = $(x.M), tol = $(x.tol), W = $(x.W))")


function interpolated_spectrum(spectrum, n)
    intp_spectrum = zeros(n)
    interpolated_spectrum!(intp_spectrum, spectrum, n)
end

function interpolated_spectrum!(intp_spectrum, spectrum, n)
    t = 1:length(spectrum)
    r = getrange(t, n)
    iₓ = itp(spectrum)
    intp_spectrum .= iₓ.(r)
    return intp_spectrum
end

function surrogenerator(x, method::IAAFT, rng = Random.default_rng())
    m = mean(x)

    # Pre-plan Fourier transforms
    forward = plan_rfft(x)
    inverse = plan_irfft(forward * x, length(x))

    # Initial forward transform.
    𝓕 = forward * x

    # For periodogram
    𝓕p = prepare_spectrum(x, forward)

    # Amplitudes of the initial transform are kept 
    # constant during iterations, so pre-allocate.
    r = abs.(𝓕)

    # Pre-allocate angles (these change during iteration)
    ϕ = abs.(𝓕)

    # Sorted values of the original time series are used for the rescaling step.
    x̂ = sort(x)

    # Initial power spectrum
    #xpower = DSP.periodogram(x).power

    # We'll re-use the plan both for periodograms and for Fourier transforms 
    # during iterations.
    xpower = zeros(length(𝓕)); powerspectrum!(𝓕p, xpower, x, forward)
    spower = copy(xpower)

    # Binned periodograms
    xpowerᵦ = interpolated_spectrum(xpower, method.W)
    spowerᵦ = interpolated_spectrum(spower, method.W)

    init = (
        forward = forward, 
        inverse = inverse, 
        𝓕 = 𝓕, 
        𝓕p = 𝓕p,
        r = r, 
        ϕ = ϕ, 
        m = m, 
        x̂ = x̂, 
        xpower = xpower, 
        spower = spower,
        xpowerᵦ = xpowerᵦ,
        spowerᵦ = spowerᵦ,
    )

    return SurrogateGenerator(method, x, similar(x), init, rng)
end
using LinearAlgebra
function (sg::SurrogateGenerator{<:IAAFT})()
    init_fields = (:forward, :inverse, :𝓕, :𝓕p, :r, :ϕ, :m, :x̂, :xpower, :spower, :xpowerᵦ, :spowerᵦ)
    forward, inverse, 𝓕, 𝓕p, r, ϕ, m, x̂, xpower, spower, xpowerᵦ, spowerᵦ = getfield.(Ref(sg.init), init_fields)

    x, s, rng = sg.x, sg.s, sg.rng
    M, W = sg.method.M, sg.method.W
    tol = sg.method.tol

    # Surrogate starts out as a random permutation of `x`
    n = length(x)
    s .= x[sample(rng, 1:n, n)]

    # Index vector used to sort in-place
    ix = zeros(Int, length(x))

    # Keep track of difference between periodograms between iterations
    sum_old, sum_new = 0.0, 0.0

    iter = 1
    while iter <= M        
        # Fourier transform of the surrogate. The forward transformation can be done 
        # in-place to avoid allocations.
        mul!(𝓕, forward, s) # 𝓕 .= forward * s
        
        # Replace amplitudes of the transform with the original amplitudes `r`,
        # leavding phases untouched.
        ϕ .= angle.(𝓕)
        𝓕 .= r .* exp.(ϕ .* 1im)

        # TODO: Unfortunately, we can't simply do ldiv! here to avoid allocations. 
        # But, although FFTW does not yet have irfft!, it will probably have. 
        # See https://github.com/JuliaMath/FFTW.jl/pull/222. 
        # Once that PR is merged, we should replace the following line with 
        # the in-place version.
        ######################################################################
        # The surrogate is initially the real part of the inverse transform.
        s .= inverse * 𝓕 

        # The inverse transform does not preserve the original values of the time series, 
        # because the phases are randomized. We therefore rank-order `s` (sort it), 
        # and replace its value with the sorted `x` values.
        sortperm!(ix, s)
        s[ix] .= x̂

        # Compute and interpolate spectrum for surrogate
        powerspectrum!(𝓕p, spower, s, forward)
        interpolated_spectrum!(spowerᵦ, spower, W)

        # Compute power spectrum for the current state of the surrogate `s` and 
        # the original power spectrum.
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
