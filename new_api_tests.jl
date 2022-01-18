using BenchmarkTools, Random

####################################
# RandomShuffle()
####################################
rng = MersenneTwister(1234)
rng2 = MersenneTwister(1234)
x = rand(10) #random_cycles(periods = 1)
rs = surrogenerator(x, RandomShuffle(), rng)
rs2 = surrogenerator(x, RandomShuffle2(), rng2)
rs(); rs2();

rs_allo  = @ballocated sg() setup = (sg = $rs)
rs2_allo = @ballocated sg() setup = (sg = $rs2)
rs_time  = @ballocated sg() setup = (sg = $rs)
rs2_time = @ballocated sg() setup = (sg = $rs2)

randomshuffle_allo = (rs_allo -  rs2_allo)/rs_allo * 100
randomshuffle_time = (rs_time -  rs2_time)/rs_time * 100
@show randomshuffle_allo, randomshuffle_time

####################################
# CycleShuffle()
####################################
rng = MersenneTwister(1234)
rng2 = MersenneTwister(1234)
x = rand(10) #random_cycles(periods = 1)
cs = surrogenerator(x, CycleShuffle(), rng)
cs2 = surrogenerator(x, CycleShuffle2(), rng2)
cs(); cs2();

cs_allo  = @ballocated sg() setup = (sg = $cs)
cs2_allo = @ballocated sg() setup = (sg = $cs2)
cs_time  = @ballocated sg() setup = (sg = $cs)
cs2_time = @ballocated sg() setup = (sg = $cs2)

randomshuffle_allo = (cs_allo -  cs2_allo)/cs_allo * 100
randomshuffle_time = (cs_time -  cs2_time)/cs_time * 100
@show randomshuffle_allo, randomshuffle_time
