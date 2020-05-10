"""
    RandomFourier(phases = true) <: Surrogate

A surrogate[^Theiler1992] that randomizes the Fourier components
of the signal in some manner. If `phases==true`, the phases are randomized,
otherwise the amplitudes are randomized.

If `phases==true`, then the resulting signal has same linear correlation, or periodogram,
as the original data.

#TODO: Okay, what happens if `phases!=true` ?

[^Theiler1992]: J. Theiler et al., [Physica D *58* (1992) 77-94 (1992)](https://www.sciencedirect.com/science/article/pii/016727899290102S)
"""
struct RandomFourier <: Surrogate
    phases::Bool
end
RandomFourier() = RandomFourier(true)

function surrogenerator(x::AbstractVector, rf::RandomFourier)
    forward = plan_rfft(x)
    inverse = plan_irfft(forward*x, length(x))
    m = mean(x)
    𝓕 = forward*(x .- m)
    init = (inverse = inverse, m = m, 𝓕 = 𝓕)
    return SurrogateGenerator(rf, x, init)
end

function (rf::SurrogateGenerator{<:RandomFourier})()
    inverse, m, 𝓕 = getfield.(Ref(rf.init), (:inverse, :m, :𝓕))
    n = length(𝓕)
    r = abs.(𝓕)
    ϕ = abs.(𝓕)
    if rf.method.phases
        randomised_ϕ = rand(Uniform(0, 2*pi), n)
        new_𝓕 = r .* exp.(randomised_ϕ .* 1im)
    else
        randomised_r = r .* rand(Uniform(0, 2*pi), n)
        new_𝓕 = randomised_r .* exp.(ϕ .* 1im)
    end
    return inverse*new_𝓕 .+ m
 end
