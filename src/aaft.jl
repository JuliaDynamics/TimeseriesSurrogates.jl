function aaft(ts)
    n = length(ts)

    # Indices that would sort `ts` in ascending order
    ts_sorted = sort(ts)

    # Phase surrogate
    phasesurr = randomphases(ts)

    # Rescale amplitudes according to original time series
    phasesurr[sortperm(phasesurr)] = ts_sorted
    return phasesurr
end
