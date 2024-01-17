using Test
using TimeseriesSurrogates
using Random
using StatsBase: autocor

n = 400 # timeseries length
rng = Xoshiro(1234567)
x = TimeseriesSurrogates.AR1(; n_steps = n, k = 0.25, rng)

q(x) = sum(autocor(x, 0:10))

test = SurrogateTest(q, x, RandomFourier(); n = 1000, rng)

# the AR1 process is much more correlated than its surrogates!
p = pvalue(test)
@test p > 0.9
p = pvalue(test; tail = :right)
@test p < 0.1

test = SurrogateTest(q, x, RandomFourier(); n = 1000, rng)
rval, vals = fill_surrogate_test!(test)
@test minimum(vals) ≤ rval ≤ maximum(vals)