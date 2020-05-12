# Random shuffle surrogates (RS)

Randomly shuffled surrogates are simply permutations of the original time series. 

Thus, they break any correlations in the signal.

```@example
using TimeseriesSurrogates
ts = AR1() # create a realization of a random AR(1) process
phases = true
s = surrogate(ts, RandomShuffle())

surrplot(ts, s)
```
