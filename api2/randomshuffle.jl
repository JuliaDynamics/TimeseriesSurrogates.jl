using BenchmarkTools, Random

####################################
# RandomShuffle()
####################################
rng = MersenneTwister(1234)
rng2 = MersenneTwister(1234)
n = 1000
x = cos.(range(0, 20π, length = n)) .+ randn(n)*0.05
rs = surrogenerator(x, RandomShuffle(), rng)
rs2 = surrogenerator(x, RandomShuffle2(), rng2)
rs(); rs2();

rs_allo  = @ballocated sg() setup = (sg = $rs)
rs2_allo = @ballocated sg() setup = (sg = $rs2)
rs_time  = @belapsed sg() setup = (sg = $rs)
rs2_time = @belapsed sg() setup = (sg = $rs2)

randomshuffle_allo = (rs_allo -  rs2_allo)/rs_allo * 100
randomshuffle_time = (rs_time -  rs2_time)/rs_time * 100
@show randomshuffle_allo, randomshuffle_time
