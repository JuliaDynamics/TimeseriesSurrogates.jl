using Random
export RandomShuffle

"""
    RandomShuffle() <: Surrogate

A random constrained surrogate, generated by shifting values around.

Random shuffle surrogates preserve the mean, variance and amplitude 
distribution of the original signal. Properties not preserved are *any 
temporal information*, such as the power spectrum and hence linear 
correlations. 

The null hypothesis this method can test for is whether the data 
are uncorrelated noise, possibly measured via a nonlinear function.
Specifically, random shuffle surrogate can test 
the null hypothesis that the original signal is produced by independent and 
identically distributed random variables[^Theiler1991, ^Lancaster2018]. 

*Beware: random shuffle surrogates do not cover the case of correlated noise*[^Lancaster2018]. 

[^Theiler1991]: J. Theiler, S. Eubank, A. Longtin, B. Galdrikian, J. Farmer, Testing for nonlinearity in time series: The method of surrogate data, Physica D 58 (1–4) (1992) 77–94.
"""
struct RandomShuffle <: Surrogate end

function surrogenerator(x::AbstractVector, rf::RandomShuffle, rng = Random.default_rng())
    n = length(x)
    idxs = collect(1:n)

    init = (
        permutation = zeros(Int, n),
        idxs = idxs,
    )

    return SurrogateGenerator2(rf, x, similar(x), init, rng)
end

function (sg::SurrogateGenerator{<:RandomShuffle})()
    # Get relevant fields from surrogate generator.
    x, s, rng = sg.x, sg.s, sg.rng
    permutation, idxs  = getfield.(Ref(sg.init), (:permutation, :idxs))
    n = length(x)
    
    # Draw a new permutation of the data
    sample!(rng, idxs, permutation; replace = false)
    s .= x[permutation]
    return s
end