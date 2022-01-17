# What is a surrogate?

## The method of surrogate testing

The method of [surrogate testing](https://en.wikipedia.org/wiki/Surrogate_data_testing)
is a statistical method for testing whether a given input timeseries `x` satisfies a specific hypothesis or not.
Surrogate testing can be used to test, for example, whether a timeseries that appears noisy represents a nonlinear dynamical system, or it instead comes from a purely stochastic and uncorrelated process.
For the suitable hypothesis to test for, see the documentation strings of provided `<: Surrogate` methods.

The actual hypothesis testing is done by computing an appropriate discriminatory statistic for the input timeseries and the surrogates.
If the statistic differs greatly between surrogate and input, then the formulated hypothesis can be rejected.
For an overview of surrogate methods and the hypotheses they can test, see the review from Lancaster et al. (2018)[^Lancaster2018].

Notice that of course another application of surrogate timeseries is to simply generate more timeseries with similar properties as `x`.



## What is a surrogate time series?
Let's say we have a nontrivial timeseries `x` consisting of `n` observations.
A surrogate time series for `x` is another timeseries `s` of `n` values which (roughly) preserves
one or many mathematical/statistical properties of `x`.

The upper panel in the figure below shows an example of a time series and one
surrogate realization that preserves its autocorrelation. The time series "look
alike", which is due to the fact the surrogate realization almost exactly preserved the
power spectrum and autocorrelation of the time series, as shown in the lower panels.

```@example
using TimeseriesSurrogates, CairoMakie
x = LinRange(0, 20π, 300) .+ 0.05 .* rand(300)
ts = sin.(x./rand(20:30, 300) + cos.(x))
s = surrogate(ts, IAAFT())

surroplot(ts, s)
```

[^Lancaster2018]: Lancaster, G., Iatsenko, D., Pidde, A., Ticcinelli, V., & Stefanovska, A. (2018). Surrogate data for hypothesis testing of physical systems. Physics Reports, 748, 1–60. doi:10.1016/j.physrep.2018.06.001
