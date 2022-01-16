---
title: 'TimeseriesSurrogates.jl: a Julia package for generating surrogate data'
tags:
  - Julia
  - surrogate data
  - time series
  - nonlinear time series analysis
  - hypothesis testing
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

# Introduction
The method of surrogate data [@Theiler:1991] is a way to generate data that preserve one or more statistical or dynamical properties of a signal, but is otherwise randomized. One can thus generate synthetic time series that "look like" or behave like the original data in some manner, but are otherwise random. Surrogate time series methods have widespread use in null hypothesis testing in nonlinear dynamics, for null hypothesis testing in causal inference, for the more general case of producing synthetic data with similar statistical properties as an original signal. Originally introduced by [@Theiler:1991] to test for nonlinearity in time series, numerous surrogate methods aimed preserving different properties of the original signal have since emerged (for a review, see [@Lancaster:2018]).

TimeseriesSurrogates.jl is part of [JuliaDynamics](https://juliadynamics.github.io/JuliaDynamics/), a GitHub organization dedicated to creating high quality scientific software for studying dynamical system.

# Statement of Need
Surrogate data has been used in several thousand publications so far (citation number of [@Theiler:1991] is more than 4,000) and hence the community is in clear need of such methods. Existing software packages for surrogate generation provide much less methods than available in the literature, and with less-than optimal performance (see Comparison section below). TimeseriesSurrogates.jl provides more than double the amount of methods given by other packages in more than 100x the speed.


# Available surrogate methods

# TODO: There are several methods missing here

| Method | Description | Reference |
|---|---|---|
| `RandomShuffling` | random shuffling of individual data points | [@Theiler:1991] |
| `BlockShuffle`  | random shuffling of blocks of data points  | [@Theiler:1991] |
| `RandomFourier`  | randomization of phases of Fourier transform of the signal  | [@Theiler:1991] |
| `AAFT`  | amplitude adjusted `RandomFourier`  | [@Theiler:1991] |
| `IAAFT`  | iterative amplitude adjusted `RandomFourier`  | [@SchreiberSchmitz:1996] |
| `TFTS`  | truncated Fourier transform phase randomization  | [@Nakamura:2006] |
| `TAAFT`  | iterative `TFTS` | [@Nakamura:2006] |
| `WLS`  | wavelet-based methods using maximal overlap discrete wavelet transforms | [@Keylock:2006] |
| `WIAAFT`  | wavelet-based iterative amplitude adjusted transforms | [@Keylock:2006] |
| `PseudoPeriodic`  | randomization of phases of Fourier transform of the signal  | [@Small:2001] |

Documentation strings for the various methods describe the usage intended by the original authors of the methods.
Example applications are showcased in the [package documentation](https://juliadynamics.github.io/TimeseriesSurrogates.jl/dev/).

# Design of TimeseriesSurrogates.jl
TimeseriesSurrogates.jl has been designed to be as performant as possible and as simple to extend as possible.

At a first level, we offer a function
```julia
method = RandomShuffle() # can be any valid method
s = surrogate(x, method, rng)
```
which creates a surrogate `s` based on the input `x` and the given method (any of the methods mentioned in the above section). `rng` is an optional random number generation object that establishes reproducibility.

This interface is easily extendable because it uses Julia's multiple dispatch on the given `method`.
Thus, any new contribution of a new method uses the exact same interface, but introduces a new method type, e.g.
```julia
m = NewContributedMethod(args...)
s = surrogate(x, method, rng)
```

The function `surrogate` is straight-forward to use, but it does not allow maximum performance.
The reason for this is that when trying to make a second surrogate from `x` and the same method, there are many structures and computations that could be pre-initialized and/or reused for all surrogates. This is especially relevant for real-world applications where one typically makes thousands of surrogates from a given method.
To address this, we provide a second level of interface, the `surrogenerator` function.
It works as follows: first the user initializes a "surrogate generator" structure:
```julia
method = RandomShuffle()
sg = surrogenerator(x, method, rng)
```
The structure `sg` can generate surrogates of `x` on demand in the most performant manner possible for the given inputs `x, method`.
It can be used like so:
```julia
for i in 1:100
    s = sg() # generate a surrogate
    # code...
end
```

# Comparison
# TODO: 
we have more methods than the matlab and python packages. 

Then, figure with performance comparison versus matlab

![Figure 1: Mean time (in seconds, based on 30 realizations) to generate a single surrogate using a pre-initialized generators for currently implemented surrogate methods in TimeseriesSurrogates.jl, using default parameters. The maximum number of iterations for the IAAFT algorithm is set to 100. A Juputer notebook in which results can be reproduced is available in the GitHub repo for this paper.](figs/mean_times_in_seconds.png)

# Acknowledgements

KAH acknowledges funding by the Trond Mohn Foundation (previously Bergen Research Foundation) (Bergen, Norway) and a fast-track initative grant from Bjerknes Centre for Climate Research (Bergen, Norway).
GD acknowledges continuous support from Bjorn Stevens and the Max Planck Society.

# References
