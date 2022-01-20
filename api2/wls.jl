using BenchmarkTools, Random

####################################
# TFTS()
####################################
rng = MersenneTwister(1234)
rng2 = MersenneTwister(1234)
x = random_cycles(rng, periods = 90)[1:5000]
wls_rp = surrogenerator(x, WLS(RandomFourier(true)), rng)
wls_rp2 = surrogenerator(x, WLS(RandomFourier(true)), rng2)
wls_rp(); wls_rp2(); 

wls_rp_bt  = @btime sg() setup = (sg = $wls_rp);
wls_rp2_bt = @btime sg() setup = (sg = $wls_rp2);