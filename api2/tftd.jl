using BenchmarkTools, Random

####################################
# TFTS()
####################################
rng = MersenneTwister(1234)
rng2 = MersenneTwister(1234)
x = random_cycles(rng, periods = 90)[1:5000]
tftd = surrogenerator(x, TFTDRandomFourier(true, 0.03), rng)
tftd2 = surrogenerator(x, TFTDRandomFourier2(true, 0.03), rng2)
tftd(); tftd2(); 

tftd_bt  = @btime sg() setup = (sg = $tftd);
tftd2_bt = @btime sg() setup = (sg = $tftd2);
# tftd_allo  = @ballocated sg() setup = (sg = $tftd)
# tftd2_allo = @ballocated sg() setup = (sg = $tftd2)
# tftd_time  = @belapsed sg() setup = (sg = $tftd)
# tftd2_time = @belapsed sg() setup = (sg = $tftd2)

# tftd_allo = (tftd_allo -  tftd2_allo)/tftd_allo * 100
# tftd_time = (tftd_time -  tftd2_time)/tftd_time * 100
# @show tftd_allo, tftd_time
