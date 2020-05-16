# Wavelet surrogates

Wavelet surrogates are constructed by taking the maximal overlap 
discrete wavelet transform (MODWT) of the signal, shuffling detail 
coefficients across dyadic scales, then inverting the transform to 
obtain the surrogate. 

## Shuffling methods

The choice of surrogate affects how well and 
which properties of the original signal is reproduced.

Using random shuffling of the detail coefficients does not preserve the 
autocorrelation structure of the original signal. 

```@example 
using TimeseriesSurrogates, Random
Random.seed!(1234);
n = 400
σ = 20
x = cumsum(randn(n)) .+ 
    [20*sin(2π/10*i) for i = 1:n] .+ 
    [20*cos(2π/50*i) for i = 1:n] .+
    [50*sin(2π/2*i + π) for i = 1:n] .+ 
    σ .* rand(n).^2;

s = surrogate(x, WLS(RandomShuffle()));
surroplot(x, s)
```


Block shuffling the detail coefficients does a better job at preserving 
the autocorrelation structure of the original signal:

```@example 
using TimeseriesSurrogates, Random
Random.seed!(1234);
n = 400
σ = 20
x = cumsum(randn(n)) .+ 
    [20*sin(2π/10*i) for i = 1:n] .+ 
    [20*cos(2π/50*i) for i = 1:n] .+
    [50*sin(2π/2*i + π) for i = 1:n] .+ 
    σ .* rand(n).^2;

s = surrogate(x, WLS(BlockShuffle()));
surroplot(x, s)
```

AAFT shuffling also does a decent job at at preserving 
the autocorrelation:

```@example
using TimeseriesSurrogates, Random
Random.seed!(1234);
n = 400
σ = 20
x = cumsum(randn(n)) .+ 
    [20*sin(2π/10*i) for i = 1:n] .+ 
    [20*cos(2π/50*i) for i = 1:n] .+
    [50*sin(2π/2*i + π) for i = 1:n] .+ 
    σ .* rand(n).^2;

s = surrogate(x, WLS(AAFT()));
surroplot(x, s)
```

## Original implementation uses IAAFT shuffling

In [Keylock (2006)](https://journals.aps.org/pre/abstract/10.1103/PhysRevE.73.036707), 
IAAAFT shuffling is used, yielding surrogates that preserve the local mean and 
variance of the original signal, but randomizes nonlinear properties of the signal.
*Note: the implementation here does not perform Keylock's last rank-ordering iteration step.*

```@example
using TimeseriesSurrogates, Distributions
n = 300
# Some noisy sine wave with modulated period
x = [sin(2π*(t + sin(t))/30) for t in 1:n] .+
    [0.4*sin(2π/(20*sin(i)) + rand(Uniform(0, 2π))) for i = 1:n] .+
    [1.5*sin(2π/(80*sin(i))) for i = 1:n]

s = surrogate(x, WLS(IAAFT()));
surroplot(x, s)
```



