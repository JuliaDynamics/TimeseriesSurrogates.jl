# What is a surrogate?

## The method of surrogate testing

The method of [surrogate testing](https://en.wikipedia.org/wiki/Surrogate_data_testing).
is a statistical method for testing properties about a dynamical system whose governing
equations is not known.
This happens when the only information we have available about the system is a time series.

Surrogate testing can be used to test, for example, the following properties
about a data set or the underlying process:
1. does the dataset show evidence of nonlinearity?
2. does the dataset show evidence of low-dimensional chaos?

But of course, it can also be used to generate more timeseries with similar properties as
X.

### What is a surrogate time series?
Let's say we have a nontrivial time series, call it X, consisting of `n` observations.
A surrogate time series for X is another time series of `n` values which (roughly) preserves
one or many mathematical/statistical properties of X.

The upper panel in the figure below shows an example of a time series and one
surrogate realization that preserves its autocorrelation.  The time series "look
alike", which is due to the fact the surrogate realization almost exactly preserved the
power spectrum and autocorrelation of the time series, as shown in the lower panels.

```@example
using TimeseriesSurrogates, Plots
x = LinRange(0, 20π, 300) .+ 0.05 .* rand(300)
ts = sin.(x./rand(20:30, 300) + cos.(x))
s = surrogate(ts, IAAFT())

surroplot(ts, s)
```
