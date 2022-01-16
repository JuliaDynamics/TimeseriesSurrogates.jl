export AAFT
"""
    AAFT()

An amplitude-adjusted-fourier-transform surrogate[^Theiler1991].

AAFT have the same linear correlation, or periodogram, and also
preserves the amplitude distribution of the original data.

AAFT can be used to test the null hypothesis that the data come from a
monotonic nonlinear transformation of a linear Gaussian process
(also called integrated white noise)[^Theiler1991].

[^Theiler1991]: J. Theiler, S. Eubank, A. Longtin, B. Galdrikian, J. Farmer, Testing for nonlinearity in time series: The method of surrogate data, Physica D 58 (1–4) (1992) 77–94.
"""
struct AAFT <: Surrogate end

function surrogenerator(x, method::AAFT, rng = Random.default_rng())
    init = surrogenerator(x, RandomFourier(true), rng)
    return SurrogateGenerator(method, x, init, rng)
end

function (rf::SurrogateGenerator{<:AAFT})()
    x = rf.x
    xs = sort(x)
    s = rf.init()
    s[sortperm(s)] .= xs
    return s
end
