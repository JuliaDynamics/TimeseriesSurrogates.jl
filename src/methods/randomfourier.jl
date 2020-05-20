export RandomFourier
"""
    RandomFourier(phases = true) <: Surrogate

A surrogate that randomizes the Fourier components
of the signal in some manner. If `phases==true`, the phases are randomized,
otherwise the amplitudes are randomized. 

Random Fourier phase surrogates[^Theiler1992] preserve the 
autocorrelation function, or power spectrum, of the original signal. 
Random Fourier amplitude surrogates preserve the mean and autocorrelation 
function but do not preserve the variance of the original. Random 
amplitude surrogates are not common in the literature, but are provided 
for convenience.

Random phase surrogates can be used to test the null hypothesis that 
the original signal was produced by a linear Gaussian process [^Theiler1992]. 

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
