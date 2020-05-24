---
title: 'TimeseriesSurrogates.jl: a Julia package for generating surrogate data'
tags:
  - Julia
  - surrogate data
  - time series
authors:
  - name: Kristian Agasøster Haaga
    orcid: 0000-0001-6880-8725
    affiliation: "1, 2, 3"
  - name: George Datseris
    orcid: 0000-0002-6427-2385
    affiliation: "4"
affiliations:
  - name: Department of Earth Science, University of Bergen, Bergen, Norway
    index: 1
  - name: K. G. Jebsen Centre for Deep Sea Research, Bergen, Norway
    index: 2
  - name: Bjerknes Centre for Climate Research, Bergen, Norway
    index: 3
  - name:  Max Planck Institute for Meteorology, Hamburg, Germany
    index: 4
date: 24 May 2020
bibliography: paper.bib
---

# TimeseriesSurrogates.jl: a Julia package for generating surrogate data

The method of surrogate data [@Theiler:1991] is a way to generate data that preserve one or more statistical or dynamical properties of a signal, but is otherwise randomized. One can thus generate synthetic time series that "look like" or behave like the original data in some manner, but are otherwise random. Surrogate time series methods have widespread use in null hypothesis testing in nonlinear dynamics, for null hypothesis testing in causal inference, for the more general case of producing synthetic data with similar statistical properties as an original signal. Originally introduced by @Theiler:1991 to test for nonlinearity in time series, numerous surrogate methods aimed preserving different properties of the original signal have since emerged (for a review, see @Lancaster:2018).

TimeseriesSurrogates.jl is part of [JuliaDynamics](https://juliadynamics.github.io/JuliaDynamics/), a GitHub organization dedicated to creating high quality scientific software for studying dynamical system.

#TODO: Example figure of a surrogate, just like in the docs.

## Available surrogate methods

TimeseriesSurrogates.jl is a software package for the Julia programming language [@Bezanson:2017] that provides performant implementations of commonly used surrogate methods, using an easily extendable interface.  As of the 1.0 release of the package, supported methods include:

- Basic methods based on random shuffling[@Theiler:1991] and random block shuffling.
- For preserving linear properties of the signal --- the autocorrelation function or power spectrum of the data --- several algorithms based on Fourier phase randomization are provided: random Fourier phase surrogates [@Theiler:1991], amplitude-ajusted Fourier transform (AAFT)[@Theiler:1991] and iterative AAFT (IAAFT) surrogates[@SchreiberSchmitz:1996]. These methods are aimed at stationary data.
- For nonstationary data, we provide modifications of the Fourier transform based surrogates where parts of the frequencies are left untouched, such as truncated Fourier transform surrogates (TFTS) and truncated AAFT (TAAFT) surrogates[@Nakamura:2006].
- Wavelet-based surrogates (WLS) surrogates are computed by taking the maximal overlap discrete wavelet transform (MODWT) of a signal, then randomizing the detail coefficients at each dyadic scale using some strategy, and finally taking the inverse MODWT to obtain a surrogate time series. In our implementation, the user controls the detail coefficient randomization and rescaling, yielding a variety of different wavelet based surrogate methods, including the wavelet-IAAFT surrogate method (WIAAFT)[@Keylock:2006].
- Pseudoperiodic surrogates (PPS)[@Small:2001].

Documentation strings for the various methods describe the usage intended by the original authors of the methods.
Example applications are showcased in the [package documentation](https://juliadynamics.github.io/TimeseriesSurrogates.jl/dev/).

## Design for a concise yet fast API
When creating surrogate timeseries, it is very often the case that the user wants to create 1000s of surrogates for an input timeseries and input surrogate method.
Because of this requirement, generating a surrogate should be as fast as possible, while still allowing an easy to use interface that remains extendable.
The design of TimeseriesSurrogates.jl is centered around these requirements.
At a first level, we offer a function
```julia
method = RandomShuffle() # can be any valid method
s = surrogate(x, method)
```
which creates a surrogate `s` based on the input `x` and the given method (any of the methods mentioned in the above section).
This interface is easily extendable because it uses Julia's multiple dispatch on the given `method`.
Thus, any new contribution of a new method uses the exact same interface, but introduces a new method type, e.g.
```julia
m = NewContributedMethod(args...)
s = surrogate(x, method)
```
As a side-benefit, this makes different methods being *arguments of a function*, instead of being *different functions*.
The latter is the approach of other packages, e.g. `randomshuffle(x), randomfourier(x), iafft(x)` are different functions that generate surrogates based on different methods.
We believe our approach is simpler to learn and makes it much easier to compare same higher level algorithms for different input surrogate methods.

The function `surrogate` is straight-forward to use, but it does not allow maximum performance.
The reason for this is that when trying to make a second surrogate from `x` and the same method, there are many structures and computations that could be pre-initialized and/or reused for all surrogates.
To this end, we provide a second level of interface, the `surrogenerator` function.
It works as follows: first the user initializes a "surrogate generator" structure:
```julia
method = RandomShuffle()
sg = surrogenerator(x, method)
```
The structure `sg` can generate surrogates of `x` on demand in the most performant manner possible for the given inputs `x, method`.
It can be used like so:
```julia
for i in 1:100
    s = sg() # generate a surrogate
    # code...
end
```
Depending on the type of the method, the interface around `surrogenerator` can have massive performance gains.
Let us demonstrate the performance difference between naively calling `surrogate` in a loop and using the `surrogenerator` method for e.g. a truncated Fourier transform method

```julia
using TimeseriesSurrogates
n, a, A, σ = 300, 0.7, 20, 15
x = cumsum(randn(n)) .+ [(1 + a*i) .+ A*sin(2π/10*i) for i = 1:n] .+
    [A^2*sin(2π/2*i + π) for i = 1:n] .+ σ .* rand(n).^2;

method = TFTS(0.05)

@time for j in 1:10000
  s = surrogate(x, method)
end
```
```
  8.203013 seconds (14.96 M allocations: 1.861 GiB, 6.24% gc time)
```

versus:

```julia
@time begin
  sg = surrogenerator(x, method)
  for j in 1:10000
    s = sg()
  end
end
```
```
  1.839767 seconds (12.12 M allocations: 1.450 GiB, 19.25% gc time)
```
This means that we can get a factor of 5 speedup simply from a smart design choice which allows us to re-use computation and memory when making surrogates.

## Acknowledgements

KAH acknowledges funding by the Trond Mohn Foundation (previously Bergen Research Foundation) (Bergen, Norway) and a fast-track initative grant from Bjerknes Centre for Climate Research (Bergen, Norway).
GD acknowledges funding from the Max Planck Society.

## References
