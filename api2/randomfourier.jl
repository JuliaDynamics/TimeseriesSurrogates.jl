using BenchmarkTools, Random

####################################
# RandomFourier()
####################################
rng = MersenneTwister(1234)
rng2 = MersenneTwister(1234)
x = random_cycles(rng, periods = 90)[1:5000]
rf = surrogenerator(x, RandomFourier(), rng)
rf2 = surrogenerator(x, RandomFourier2(), rng2)
rf(); rf2();

rf_bt  = @btime sg() setup = (sg = $rf);
rf2_bt = @btime sg() setup = (sg = $rf2);

# rf_allo  = @ballocated sg() setup = (sg = $rf)
# rf2_allo = @ballocated sg() setup = (sg = $rf2)
# rf_time  = @belapsed sg() setup = (sg = $rf)
# rf2_time = @belapsed sg() setup = (sg = $rf2)

# randomfourier_allo = (rf_allo -  rf2_allo)/rf_allo * 100
# randomfourier_time = (rf_time -  rf2_time)/rf_time * 100
# @show randomfourier_allo, randomfourier_time
