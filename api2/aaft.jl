using BenchmarkTools, Random

####################################
# AAFT()
####################################
rng = MersenneTwister(1234)
rng2 = MersenneTwister(1234)
n = 1000
x = cos.(range(0, 20π, length = n)) .+ randn(n)*0.05
aaft = surrogenerator(x, AAFT(), rng)
aaft2 = surrogenerator(x, AAFT2(), rng2)
aaft(); aaft2();

aaft_allo  = @ballocated sg() setup = (sg = $aaft)
aaft2_allo = @ballocated sg() setup = (sg = $aaft2)
aaft_time  = @belapsed sg() setup = (sg = $aaft)
aaft2_time = @belapsed sg() setup = (sg = $aaft2)

aaft_allo = (aaft_allo -  aaft2_allo)/aaft_allo * 100
aaft_time = (aaft_time -  aaft2_time)/aaft_time * 100
@show aaft_allo, aaft_time
