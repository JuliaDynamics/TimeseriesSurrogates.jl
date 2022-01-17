# Truncated FT/AAFT surrogates

## TFTS

Truncated Fourier transform surrogates preserve some portion of the frequency spectrum of
the original signal. Here, we randomize the 95% highest frequencies, while keeping the
5% lowermost frequencies intact.

```@example MAIN
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

```@example MAIN
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

## TAAFT

Truncated AAFT surrogates are similar to TFTS surrogates, but adds the extra step of rescaling back
to the original values of the signal, so that the original signal and the surrogates consists of
the same values.

```@example MAIN
using TimeseriesSurrogates
n = 300
a = 0.7
A = 20
σ = 15
x = cumsum(randn(n)) .+ [(1 + a*i) .+ A*sin(2π/10*i) for i = 1:n] .+
    [A^2*sin(2π/2*i + π) for i = 1:n] .+ σ .* rand(n).^2;


fϵ = 0.05
s_tfts = surrogate(x, TAAFT(fϵ))
surroplot(x, s_tfts)
```


```@example MAIN
using TimeseriesSurrogates
n = 300
a = 0.7
A = 20
σ = 15
x = cumsum(randn(n)) .+ [(1 + a*i) .+ A*sin(2π/10*i) for i = 1:n] .+
    [A^2*sin(2π/2*i + π) for i = 1:n] .+ σ .* rand(n).^2;

fϵ = -0.2
s_tfts = surrogate(x, TAAFT(fϵ))
surroplot(x, s_tfts)
```
