"""
    aaft(ts::AbstractArray{T, 1} where T)

Generate a realization of an amplitude adjusted Fourier transform (AAFT) surrogate [1].

**`ts`** Is the time series for which to generate an AAFT surrogate realization.

# Literature references
1. J. Theiler et al., Physica D *58* (1992) 77-94 (1992).

"""
function aaft(ts::AbstractArray{T, 1} where T)
    n = length(ts)

    # Indices that would sort `ts` in ascending order
    ts_sorted = sort(ts)

    # Phase surrogate
    phasesurr = randomphases(ts)

    # Rescale amplitudes according to original time series
    phasesurr[sortperm(phasesurr)] = ts_sorted
    return phasesurr
end
