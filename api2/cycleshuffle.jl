using BenchmarkTools, Random

####################################
# CycleShuffle()
####################################
rng = MersenneTwister(1234)
rng2 = MersenneTwister(1234)
n = 5000
x = cos.(range(0, 20π, length = n)) .+ randn(n)*0.05

cs = surrogenerator(x, CycleShuffle(), rng); cs(); 
cs2 = surrogenerator(x, CycleShuffle2(), rng2); cs2();

cs_bt  = @btime sg() setup = (sg = $cs);
cs2_bt = @btime sg() setup = (sg = $cs2);

# cs_allo  = @ballocated sg() setup = (sg = $cs) samples = 100000
# cs2_allo = @ballocated sg() setup = (sg = $cs2) samples = 100000
# cs_time  = @belapsed sg() setup = (sg = $cs) samples = 100000
# cs2_time = @belapsed sg() setup = (sg = $cs2) samples = 100000

# cycleshuffle_allo = (cs_allo -  cs2_allo)/cs_allo * 100
# cycleshuffle_time = (cs_time -  cs2_time)/cs_time * 100
# @show cycleshuffle_allo, cycleshuffle_time
