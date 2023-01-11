# Crash-course in timeseries surrogate testing

!!! note
    The summary here follows Sect. 7.4 from [Nonlinear Dynamics](https://link.springer.com/book/10.1007/978-3-030-91032-7) by Datseris and Parlitz.


## What is a surrogate timeseries?
Let's say we have a nontrivial timeseries `x` consisting of `n` observations.
A surrogate time series for `x` is another timeseries `s` of `n` values which (roughly) preserves
one or many mathematical/statistical properties of `x`.

The upper panel in the figure below shows an example of a timeseries and one
surrogate realization that preserves its autocorrelation. The time series "look
alike", which is due to the fact the surrogate realization almost exactly preserved the
power spectrum and autocorrelation of the time series, as shown in the lower panels.

```@example MAIN
using TimeseriesSurrogates, CairoMakie, Makie
x = LinRange(0, 20π, 300) .+ 0.05 .* rand(300)
ts = sin.(x./rand(20:30, 300) + cos.(x))
s = surrogate(ts, IAAFT())

surroplot(ts, s)
```

## Performing surrogate hypothesis tests

A surrogate test is a statistical test of whether a given timeseries satisfies or not a given hypothesis regarding its properties or origin.

For example, the first surrogate methods were created to test the hypothesis,
whether a given timeseries `x` that appears noisy may be the result of a linear
stochastic process or not. If not, it may be a nonlinear process contaminated with observational noise. For the suitable hypothesis to test for, see the documentation strings of provided `Surrogate` methods or, even better, the review from Lancaster et al. (2018)[^Lancaster2018].

To perform such a surrogate test, you need to:

1. Decide what hypothesis to test against
2. Pick a surrogate generating `method` that satisfies the chosen hypothesis
3. Pick a suitable discriminatory statistic `q(x) ∈ Real`. It must be a statistic that would obtain sufficiently different values for timeseries satisfying, or not, the chosen hypothesis.
4. Compute `q(x)` and `q(s)` for thousands of surrogate realizations `s = surrogate(x, method)`
5. Compare `q(x)` with the distribution of `q(s)`. If `q(x)` is significantly outside the e.g., 5-95 confidence interval of the distribution, the hypothesis is rejected.

[^Lancaster2018]: Lancaster, G., Iatsenko, D., Pidde, A., Ticcinelli, V., & Stefanovska, A. (2018). Surrogate data for hypothesis testing of physical systems. Physics Reports, 748, 1–60. doi:10.1016/j.physrep.2018.06.001
