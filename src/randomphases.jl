"""
    RandomFourier([x,] phases = true) <: Surrogate

Create a random phases surrogate[^Theiler1992] that randomizes the Fourier components
of the signal in some manner. If `phases==true`, the phases are randomized,
otherwise the amplitudes.

The resulting signal has same linear correlation, or periodogram, as the original data.

If the timeseries `x` is provided, fourier transforms are planned, enabling more efficient
use of the same method for many surrogates of a signal with same length and eltype.

[^Theiler1992]: [J. Theiler et al., Physica D *58* (1992) 77-94 (1992)](https://www.sciencedirect.com/science/article/pii/016727899290102S)
"""
struct RandomFourier{F, I} <: Surrogate
    forward::F
    inverse::I
    phases::Bool
end
RandomFourier(x::Bool=true) = RandomFourier(nothing, nothing, x)
function RandomFourier(s::AbstractVector, x::Bool=true)
    forward = plan_rfft(s)
    inverse = plan_irfft(forward*s, length(s))
    return RandomFourier(forward, inverse, x)
end

function surrogate(x::AbstractVector{T}, method::RandomFourier) where T
    n = length(ts)
    m = mean(x)
    𝓕 = isnothing(method.forward) ? rfft(x .- m) : method.forward*(x .- m)

    # Polar coordinate representation of the Fourier transform
    r = abs.(𝓕)
    ϕ = angle.(𝓕)

    if method.phases
        # Create random phases ϕ on the interval [0, 2π].
        if n % 2 == 0
            midpoint = round(Int, n / 2)
            random_ϕ = rand(Uniform(0, 2*pi), midpoint)
            new_ϕ = [random_ϕ; -reverse(random_ϕ)]
        else
            midpoint = floor(Int, n / 2)
            random_ϕ = rand(Uniform(0, 2*pi), midpoint)
            new_ϕ = [random_ϕ; random_ϕ[end]; -reverse(random_ϕ)]
        end
        # Inverse Fourier transform of the original amplitudes, but with randomised phases.
        new_𝓕 = r .* exp.(new_ϕ .* 1im)
    else
        randomised_amplitudes = r .* rand(Uniform(0, 2*pi), n)
        new_𝓕 = randomised_amplitudes .* exp.(ϕ .* 1im)
    end
    s = isnothing(method.inverse) ? irfft(new_𝓕, length(x)) : method.inverse*new_𝓕
end
