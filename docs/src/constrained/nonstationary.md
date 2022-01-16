# Surrogate for nonstationary time series

For time series with strong linear trends, Lucio et al. (2012)[^Lucio2012] proposes variants 
of the Fourier-based surrogates wherein the trend is removed prior to surrogate generation,
and then added to the surrogate again after it has been generated. Functionally, this 
yields surrogates similar to those obtained when using truncated Fourier 
surrogates (e.g. [`TFTS`](@ref)). 

Here, we provide the [`RandomFourierTD`](@ref) surrogate.

## Random fourier with trend removal/addition

```@example
using TimeseriesSurrogates
n = 300
a = 0.7
A = 20
σ = 15
x = cumsum(randn(n)) .+ [(1 + a*i) .+ A*sin(2π/10*i) for i = 1:n] .+
    [A^2*sin(2π/2*i + π) for i = 1:n] .+ σ .* rand(n).^2;

s = surrogate(x, TFTDRandomFourier(true))

surroplot(x, s)
```

[^Lucio2012]: Lucio, J. H., Valdés, R., & Rodríguez, L. R. (2012). Improvements to surrogate data methods for nonstationary time series. Physical Review E, 85(5), 056202.
