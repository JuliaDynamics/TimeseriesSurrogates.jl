using BenchmarkTools, Random

####################################
# TFTS()
####################################
rng = MersenneTwister(1234)
rng2 = MersenneTwister(1234)
x = random_cycles(rng, periods = 90)[1:5000];
wls = surrogenerator(x, WLS(IAAFT()), rng);
wls2 = surrogenerator(x, WLS2(IAAFT2()), rng2);
wls(); wls2(); 

wls(); @btime sg() setup = (sg = $wls);
wls2(); @btime sg() setup = (sg = $wls2);