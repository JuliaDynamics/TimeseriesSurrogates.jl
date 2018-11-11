"""
Generate a wavelet iteratively adjusted amplitude adjusted Fourier transform (WIAAFT) [1]
surrogate series for `ts`. Preserves mean and variance structure of the signal, but
randomises nonlinear properties of the signal (i.e. Hurst exponents) [1].

[1] C.J. Keylock (2006). "Constrained surrogate time series with preservation of the mean
and variance structure". Phys. Rev. E. 73: 036707. doi:10.1103/PhysRevE.73.036707.

"""
function wiaaft(ts; n_maxiter = 100, tol = 1e-5, n_windows = 50)

    # Find the maximum number of levels possible with these data
    L = maxtransformlevels(ts)

    # Create a Daubechies wavelet with 16 vanishing moments and periodic boundary conditions
    wt = wavelet(WT.Daubechies{16}(), WT.Periodic)

    # Do the discrete wavelet transform across levels 1:L
    t = [dwt(ts, wt, i) for i = 1:L]

    # Constrained realization of the coefficients at each level by
    # iAAFT algorithm (treating the coefficients as a time series)
    coeff_surrogates = [iaaft(t[i]) for i in 1:L]

    # Mirror the surrogates
    mirror_surrogates = [reverse(x) for x in coeff_surrogates]

    n = length(ts)
    surrogate_coeffs = Vector{Float64}(undef, n)
    mirror_coeffs = Vector{Float64}(undef, n)
    selected_coeffs = Vector{Float64}(undef, n)
    surrogate = Vector{Float64}(undef, n)
    surrogates = Vector{Tuple{Int, Vector{Float64}, Vector{Float64}, Vector{Float64}}}(undef, 0)
    for dyadic_scale = 1:L
        surrogate_coeffs[:] = iaaft(coeff_surrogates[dyadic_scale])
        mirror_coeffs[:] = reverse(surrogate_coeffs)

        # Circularly rotate to minimize error function
        min_errors = Vector{Float64}(undef, 2)
        [min_errors[i] = Inf for i in 1:2]

        errors = Vector{Float64}(undef, 2)
        shift_minimising_errfunc = Vector{Int}(undef, 2)
        for i in 0:n-1
            errors[1] = rmsd(coeff_surrogates[dyadic_scale],
                            circshift(surrogate_coeffs, i))
            errors[2] = rmsd(coeff_surrogates[dyadic_scale],
                            circshift(mirror_coeffs, i))

            if errors[1] < min_errors[1]
                min_errors[1] = errors[1]
                shift_minimising_errfunc[1] = i
            end

            if errors[2] < min_errors[2]
                min_errors[2] = errors[2]
                shift_minimising_errfunc[2] = i
            end
        end
        if min_errors[1] < min_errors[2]
            selected_coeffs[:] = circshift(surrogate_coeffs, shift_minimising_errfunc[1])
        else
            selected_coeffs[:] = circshift(mirror_coeffs, shift_minimising_errfunc[2])
        end

        # Invert the DWT on original
        inverted =  idwt(coeff_surrogates[dyadic_scale], wt, dyadic_scale)
        inverted_surrogate = idwt(selected_coeffs, wt, dyadic_scale)

        surrogate[sortperm(inverted_surrogate)] = sort(inverted)
        surrogate[sortperm(inverted)] = sort(ts)
        
        push!(surrogates, (dyadic_scale, inverted, inverted_surrogate, surrogate[:]))
    end

    return surrogates
end

export wiaaft
