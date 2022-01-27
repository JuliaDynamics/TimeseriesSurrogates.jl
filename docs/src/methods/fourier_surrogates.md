# Fourier-based

Fourier based surrogates are a form of constrained surrogates created by taking the Fourier
transform of a time series, then shuffling either the phase angles or the amplitudes of the resulting complex numbers. Then, we take the inverse Fourier transform, yielding a surrogate time series.

## Random phase

```@example MAIN
using TimeseriesSurrogates, CairoMakie
ts = AR1() # create a realization of a random AR(1) process
phases = true
s = surrogate(ts, RandomFourier(phases))

surroplot(ts, s)
```

## Random amplitude

```@example MAIN
using TimeseriesSurrogates, CairoMakie
ts = AR1() # create a realization of a random AR(1) process
phases = false
s = surrogate(ts, RandomFourier(phases))

surroplot(ts, s)
```


 ## Partial randomization

 ### Without rescaling 

 [`PartialRandomization`](@ref) surrogates are similar to random phase surrogates, 
 but allows for tuning the "degree" of phase randomization.

```@example MAIN
using TimeseriesSurrogates, CairoMakie
ts = AR1() # create a realization of a random AR(1) process

# 50 % randomization of the phases
s = surrogate(ts, PartialRandomization(0.5))

surroplot(ts, s)
```

### With rescaling

[`PartialRandomizationAAFT`](@ref) adds a rescaling step to the [`PartialRandomization`](@ref) surrogates to obtain surrogates that contain the same values as the original time 
series.

```@example MAIN
using TimeseriesSurrogates, CairoMakie
ts = AR1() # create a realization of a random AR(1) process

# 50 % randomization of the phases
s = surrogate(ts, PartialRandomizationAAFT(0.7))

surroplot(ts, s)
```

## Amplitude adjusted Fourier transform (AAFT)


```@example MAIN
using TimeseriesSurrogates, CairoMakie, Makie
ts = AR1() # create a realization of a random AR(1) process
s = surrogate(ts, AAFT())

surroplot(ts, s)
```

## Iterative AAFT (IAAFT)

The IAAFT surrogates add an iterative step to the AAFT algorithm to improve similarity
of the power spectra of the original time series and the surrogates.

```@example MAIN
using TimeseriesSurrogates, CairoMakie, Makie
ts = AR1() # create a realization of a random AR(1) process
s = surrogate(ts, IAAFT())

surroplot(ts, s)
```

### Phase surrogates (TFTS)

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

### Amplitude-adjusted phase surrogates (TAAFT)

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