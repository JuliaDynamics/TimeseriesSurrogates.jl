"""
    aaft(ts::AbstractArray{T, 1} where T)

Generate a realization of an amplitude adjusted Fourier transform (AAFT)
surrogate ([Theiler et al., 1992](https://www.sciencedirect.com/science/article/pii/016727899290102S)).

# Arguments
 - **`ts`**: the time series for which to generate the surrogate realization.

# References

J. Theiler et al., Physica D *58* (1992) 77-94 (1992).
[https://www.sciencedirect.com/science/article/pii/016727899290102S](https://www.sciencedirect.com/science/article/pii/016727899290102S)

"""
function aaft(ts::AbstractArray{T, 1} where T)
    any(isnan.(ts)) && throw(DomainError(NaN, "The input must not contain NaN values"))
    n = length(ts)

    # Indices that would sort `ts` in ascending order
    ts_sorted = sort(ts)

    # Phase surrogate
    phasesurr = randomphases(ts)

    # Rescale amplitudes according to original time series
    phasesurr[sortperm(phasesurr)] = ts_sorted
    return phasesurr
end
