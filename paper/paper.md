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

`TimeseriesSurrogates.jl` is a software package for the Julia programming language [@Bezanson:2017] that provides performant implementations of commonly used surrogate methods, using an easily extendable interface.  As of the 1.0 release of the package, supported methods include:

- Basic methods based on random shuffling[@Theiler:1991] and random block shuffling. 
- For preserving linear properties of the signal --- the autocorrelation function or power spectrum of the data --- several algorithms based on Fourier phase randomization are provided: random Fourier phase surrogates [@Theiler:1991], amplitude-ajusted Fourier transform (AAFT)[@Theiler:1991] and iterative AAFT (IAAFT) surrogates[@SchreiberSchmitz:1996]. These methods are aimed at stationary data. 
- For nonstationary data, we provide modifications of the Fourier transform based surrogates where parts of the frequencies are left untouched, such as truncated Fourier transform surrogates (TFTS) and truncated AAFT (TAAFT) surrogates[@Nakamura:2006]. 
- Wavelet-based surrogates (WLS) surrogates are computed by taking the maximal overlap discrete wavelet transform (MODWT) of a signal, then randomizing the detail coefficients at each dyadic scale using some strategy, and finally taking the inverse MODWT to obtain a surrogate time series. In our implementation, the user controls the detail coefficient randomization and rescaling, yielding a variety of different wavelet based surrogate methods, including the wavelet-IAAFT surrogate method (WIAAFT)[@Keylock:2006].
- Pseudoperiodic surrogates (PPS)[@Small:2001].

Documentation strings for the various methods describe the usage inteded by the original authors of the methods, as well as any discrepancies between our implementations and the original algorithms. Example applications are showcased in the package documentation.

``TimeseriesSurrogates.jl`` is part of [JuliaDynamics](https://juliadynamics.github.io/JuliaDynamics/), a GitHub organization dedicated to creating high quality scientific software for studying dynamical system. Originally, ``TimeseriesSurrogates.jl`` was developed to provide a machinery for hypothesis testing for causal inference in the ``CausalityTools.jl`` Julia package (also part of JuliaDynamics), but is now provided as a stand-alone package due to its widespread usefulness in the study of dynamical systems.


# References