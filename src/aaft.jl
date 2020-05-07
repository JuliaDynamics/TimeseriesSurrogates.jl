"""
    AAFT([x,])
An amplitude-adjusted-fourier-transform surrogate[^Theiler1992].

If the timeseries `x` is provided, fourier transforms are planned, enabling more efficient
use of the same method for many surrogates of a signal with same length and eltype as `x`.

TODO: Write what properties are kept constant here.

[^Theiler1992]: [J. Theiler et al., Physica D *58* (1992) 77-94 (1992)](https://www.sciencedirect.com/science/article/pii/016727899290102S)
"""
struct AAFT{F, I} <: Surrogate
    forward::F
    inverse::I
end
AAFT(x) = RandomFourier(nothing, nothing)

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
