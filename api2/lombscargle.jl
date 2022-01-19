using BenchmarkTools, Random

####################################
# IrregularLombScargle()
####################################
rng = MersenneTwister(1234)
rng2 = MersenneTwister(1234)
n = 1000
x = cos.(range(0, 20π, length = n)) .+ randn(n)*0.05
t = collect(1:n) .+ rand(n)
lombscargle = surrogenerator(x, IrregularLombScargle(t, tol = 10), rng)
lombscargle2 = surrogenerator(x, IrregularLombScargle2(t, tol = 10), rng2)
lombscargle(); lombscargle2();

lombscargle_allo  = @ballocated sg() setup = (sg = $lombscargle)
lombscargle2_allo = @ballocated sg() setup = (sg = $lombscargle2)
lombscargle_time  = @belapsed sg() setup = (sg = $lombscargle)
lombscargle2_time = @belapsed sg() setup = (sg = $lombscargle2)

lombscargle_allo = (lombscargle_allo -  lombscargle2_allo)/lombscargle_allo * 100
lombscargle_time = (lombscargle_time -  lombscargle2_time)/lombscargle_time * 100
@show lombscargle_allo, lombscargle_time
