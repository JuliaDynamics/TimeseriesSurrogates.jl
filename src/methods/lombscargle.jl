using LombScargle, Distances

export LS

"""
    LS(t; tol = 1, n_total = 20000, n_acc = 5000, q = 1)

Compute a surrogate of an unevenly sampled time series with supporting time steps `t` based on 
the simulated annealing algorithm described in [^SchreiberSchmitz1999].

LS surrogates preserve the periodogram and the amplitude distribution of the original signal.
For time series with equidistant time steps, surrogates generated by this method result in 
surrogest similar to those produced by the [`IAAFT`](@ref) method.

This algorithm starts with a random permutation of the original data. Then it iteratively 
approaches the power spectrum of the original data by swapping two randomly selected values 
in the surrogate data if the Minkowski distance of order `q` between the power spectrum of 
the surrogate data and the original data is less than before. The iteration procedure ends 
when the relative deviation between the periodograms is less than `tol` or when `n_total` 
number of tries or `n_acc` number of actual swaps is reached.

[^SchmitzSchreiber1999]: A.Schmitz T.Schreiber (1999). "Testing for nonlinearity in unevenly sampled time series" [Phys. Rev E](https://journals.aps.org/pre/pdf/10.1103/PhysRevE.59.4044)
"""
struct LS{T<:AbstractVector, S<:Real} <: Surrogate
    t::T
    tol::S
    n_total::Int
    n_acc::Int
    q::Int
end

LS(t; tol = 1.0, n_total = 50000, n_acc = 5000, q = 1) = LS(t, tol, n_total, n_acc, q)


function surrogenerator(x, method::LS, rng = Random.default_rng())
    # Plan Lombscargle periodogram. Use default flags.
    lsplan = LombScargle.plan(method.t, x, fit_mean = false)

    # Compute initial periodogram.
    x_ls = lombscargle(lsplan)

    # We have to copy the power vector here, because we are reusing `lsplan` later on
    xpower = copy(x_ls.power)

    # Use Minkowski distance of order q
    dist = Distances.Minkowski(method.q)

    init = (lsplan = lsplan, xpower = xpower, n = length(x), dist = dist)
    return SurrogateGenerator(method, x, init, rng)
end


function (sg::SurrogateGenerator{<:LS})()
    lsplan, xpower, n, dist = sg.init
    t = sg.method.t
    tol = sg.method.tol
    rng = sg.rng

    # When re-computing the Lomb-Scargle periodogram, we will use the 
    # `_periodogram!` method, which re-uses the lsplan with a shuffled 
    # time vector. This is the same as shuffling the signal, so the 
    # surrogate starts out as a shuffled version of `t`.
    s = surrogate(t, RandomShuffle())
    
    # Power spectrum for the randomly shuffled signal.
    spower = LombScargle._periodogram!(lsplan.P, s, lsplan)

    # Compare power spectra for original (`xpower`) and randomly shuffled signal (`spower`).
    lossold = Distances.evaluate(dist, xpower, spower)

    # Initialize a new candidate surrogate.
    candidate_s = zero(s)

    i = j = 0
    while i < sg.method.n_total && j < sg.method.n_acc
        if mod(i, 2000) == 0
            @info "iterations: $i, swaps: $j, loss: $lossold"
        end

        # Initially, the new surrogate is identical to the existing surrogate.
        copy!(candidate_s, s)

        # Swap two random points and re-compute power spectrum for the candidate.
        k, l = sample(rng, 1:n, 2, replace = false)
        candidate_s[[k, l]] = s[[l, k]]
        spower = LombScargle._periodogram!(lsplan.P, candidate_s, lsplan)

        # If spectra are more similar after the swap, accept the new 
        # surrogate. Otherwise, do a new swap.
        lossnew = evaluate(dist, xpower, spower)

        if lossnew < lossold
            lossnew <= tol && break
            s = copy(candidate_s)
            lossold = lossnew
            j += 1
        end
        i += 1
    end
    @info "Terminated simulated annealing process after $i iterations and $j swaps. Loss: $lossold"

    # Use the permutation of the time vector to permute the signal vector
    # This gives us the inverse permutation from t to perm
    perm = sortperm(sortperm(s))

    # Check if this worked as expected
    @assert t[perm] == s
    
    # Re-scale back to original time series values.
    return sg.x[perm]
end