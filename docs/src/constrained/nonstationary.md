# Surrogates for nonstationary time series


## Truncated FT/AAFT surrogates

### [`TFTS`](@ref)

Truncated Fourier transform surrogates ([`TFTS`](@ref)) preserve some portion of the 
frequency spectrum of the original signal. Here, we randomize the 95% highest 
frequencies, while keeping the 5% lowermost frequencies intact.

```@example
using TimeseriesSurrogates
n = 300
a = 0.7
A = 20
σ = 15
x = cumsum(randn(n)) .+ [(1 + a*i) .+ A*sin(2π/10*i) for i = 1:n] .+
    [A^2*sin(2π/2*i + π) for i = 1:n] .+ σ .* rand(n).^2;


fϵ = 0.05
s_tfts = surrogate(x, TFTS(fϵ))
surroplot(x, s_tfts)
```

One may also choose to preserve the opposite end of the frequency spectrum. Below,
we randomize the 20% lowermost frequencies, while keeping the 80% highest frequencies
intact.

```@example
using TimeseriesSurrogates
n = 300
a = 0.7
A = 20
σ = 15
x = cumsum(randn(n)) .+ [(1 + a*i) .+ A*sin(2π/10*i) for i = 1:n] .+
    [A^2*sin(2π/2*i + π) for i = 1:n] .+ σ .* rand(n).^2;

fϵ = -0.2
s_tfts = surrogate(x, TFTS(fϵ))
surroplot(x, s_tfts)
```

### [`TAAFT`](@ref)

Truncated AAFT surrogates ([`TAAFT`](@ref)) are similar to TFTS surrogates, but adds the 
extra step of rescaling back to the original values of the signal, so that the original 
signal and the surrogates consists of the same values.


```@example
using TimeseriesSurrogates

# Example signal
n = 300; a = 0.7; A = 20; σ = 15
x = cumsum(randn(n)) .+ [(1 + a*i) .+ A*sin(2π/10*i) for i = 1:n] .+
    [A^2*sin(2π/2*i + π) for i = 1:n] .+ σ .* rand(n).^2;

# Preserve 5% of the power spectrum corresponding to the lowest frequencies
s_taaft_lo = surrogate(x, TAAFT(0.05))
surroplot(x, s_taaft_lo)
```

```@example
using TimeseriesSurrogates

# Example signal
n = 300; a = 0.7; A = 20; σ = 15
x = cumsum(randn(n)) .+ [(1 + a*i) .+ A*sin(2π/10*i) for i = 1:n] .+
    [A^2*sin(2π/2*i + π) for i = 1:n] .+ σ .* rand(n).^2;

# Preserve 20% of the power spectrum corresponding to the highest frequencies
s_taaft_hi = surrogate(x, TAAFT(-0.2))
surroplot(x, s_taaft_hi)
```

## Truncated FT surrogates with trend removal/addition

For time series with strong trends, Lucio et al. (2012)[^Lucio2012] proposes variants 
of the truncated Fourier-based surrogates wherein the trend is removed prior to
surrogate generation, and then added to the surrogate again after it has been generated. 
This yields surrogates quite similar to those obtained when using truncated Fourier 
surrogates (e.g. [`TFTS`](@ref)), but reducing the effects of endpoint mismatch that 
affects regular truncated Fourier transform based surrogates.

In principle, any trend could be removed/added to the signal. For now, the only 
option is to remove a best-fit linear trend obtained by ordinary least squares 
regression.

### [`TFTDRandomFourier`](@ref)

The [`TFTDRandomFourier`](@ref) surrogate is a random Fourier surrogate where 
the lowest frequencies are preserved during surrogate generation, and a 
linear trend is removed during preprosessing and added again after the 
surrogate has been generated. 

```@example
using TimeseriesSurrogates

# Example signal
n = 300; a = 0.7; A = 20; σ = 15
x = cumsum(randn(n)) .+ [(1 + a*i) .+ A*sin(2π/10*i) for i = 1:n] .+
    [A^2*sin(2π/2*i + π) for i = 1:n] .+ σ .* rand(n).^2;

s = surrogate(x, TFTDRandomFourier(true, 0.02))
surroplot(x, s)
```

[^Lucio2012]: Lucio, J. H., Valdés, R., & Rodríguez, L. R. (2012). Improvements to surrogate data methods for nonstationary time series. Physical Review E, 85(5), 056202.
