using BenchmarkTools, Random

####################################
# AAFT()
####################################
rng = MersenneTwister(1234)
rng2 = MersenneTwister(1234)
x = random_cycles(rng, periods = 90)[1:5000]
iaaft = surrogenerator(x, IAAFT(M = 50), rng)
iaaft2 = surrogenerator(x, IAAFT2(M = 50), rng2)
iaaft(); iaaft2();

iaaft_bt  = @btime sg() setup = (sg = $iaaft);
iaaft2_bt = @btime sg() setup = (sg = $iaaft2);
# iaaft_allo  = @ballocated sg() setup = (sg = $iaaft);
# iaaft2_allo = @ballocated sg() setup = (sg = $iaaft2);
# iaaft_time  = @belapsed sg() setup = (sg = $iaaft);
# iaaft2_time = @belapsed sg() setup = (sg = $iaaft2);

# iaaft_allo = (iaaft_allo -  iaaft2_allo)/iaaft_allo * 100
# iaaft_time = (iaaft_time -  iaaft2_time)/iaaft_time * 100
# @show iaaft_allo, iaaft_time
