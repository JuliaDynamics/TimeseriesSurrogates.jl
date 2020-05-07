"""
    AAFT([x,])

An amplitude-adjusted-fourier-transform surrogate[^Theiler1992].

AAFT have the same linear correlation, or periodogram, and also 
preserves the amplitude distribution of the original data.

If the timeseries `x` is provided, fourier transforms are planned, enabling more efficient
use of the same method for many surrogates of a signal with same length and eltype as `x`.

[^Theiler1992]: J. Theiler et al., Physica D *58* (1992) 77-94 (1992)](https://www.sciencedirect.com/science/article/pii/016727899290102S)
"""
struct AAFT{F, I} <: Surrogate
    forward::F
    inverse::I
end
AAFT() = AAFT(nothing, nothing)

function AAFT(s::AbstractVector)
    forward = plan_rfft(s)
    inverse = plan_irfft(forward*s, length(s))
    return AAFT(forward, inverse)
end

function surrogate(x::AbstractVector, method::AAFT)
    xs = sort(x)
    s = surrogate(x, RandomFourier(method.forward, method.inverse, true))
    # Rescale amplitudes according to original time series
    s[sortperm(s)] .= xs
    return s
end

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
