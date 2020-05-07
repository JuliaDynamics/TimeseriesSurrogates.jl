"""
    RandomFourier([x,] phases = true) <: Surrogate

A surrogate[^Theiler1992] that randomizes the Fourier components
of the signal in some manner. If `phases==true`, the phases are randomized,
otherwise the amplitudes are randomized.

If `phases==true`, then the resulting signal has same linear correlation, or periodogram, 
as the original data.

If the timeseries `x` is provided, fourier transforms are planned, enabling more efficient
use of the same method for many surrogates of a signal with same length and eltype as `x`.

## References

[^Theiler1992]: [J. Theiler et al., Physica D *58* (1992) 77-94 (1992)](https://www.sciencedirect.com/science/article/pii/016727899290102S)
"""
struct RandomFourier{F, I} <: Surrogate
    forward::F
    inverse::I
    phases::Bool
end

RandomFourier(phases::Bool=true) = RandomFourier(nothing, nothing, phases)
function RandomFourier(x::AbstractVector, phases::Bool=true)
    forward = plan_rfft(x)
    inverse = plan_irfft(forward*x, length(x))
    return RandomFourier(forward, inverse, phases)
end

function surrogate(x::AbstractVector{T}, method::RandomFourier) where T
    m = mean(x)
    𝓕 = isnothing(method.forward) ? rfft(x .- m) : method.forward*(x .- m)
    n = length(𝓕)
 
    # Polar coordinate representation of the Fourier transform
    r = abs.(𝓕)
    ϕ = angle.(𝓕)
    
    if method.phases
        randomised_ϕ = rand(Uniform(0, 2*pi), n)
        new_𝓕 = r .* exp.(randomised_ϕ .* 1im)
    else
        randomised_r = r .* rand(Uniform(0, 2*pi), n)
        new_𝓕 = randomised_r .* exp.(ϕ .* 1im)
    end
    
    isnothing(method.inverse) ? irfft(new_𝓕, length(x)) : method.inverse*new_𝓕
 end
