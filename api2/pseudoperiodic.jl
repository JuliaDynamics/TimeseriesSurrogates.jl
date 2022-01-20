using BenchmarkTools, Random

####################################
# PseudoPeriodicTwin()
####################################
rng = MersenneTwister(1234)
rng2 = MersenneTwister(1234)
n = 5000
x = cos.(range(0, 20π, length = n)) .+ randn(n)*0.05
d, τ = 2, 6
ρ = noiseradius(x, d, τ, 0.02:0.02:0.5)
pps = surrogenerator(x, PseudoPeriodic(d, τ, ρ), rng)
pps2 = surrogenerator(x, PseudoPeriodic2(d, τ, ρ), rng2)
pps(); pps2();

pps_bt  = @btime sg() setup = (sg = $pps);
pps2_bt = @btime sg() setup = (sg = $pps2);

# pps_allo  = @ballocated sg() setup = (sg = $pps)
# pps2_allo = @ballocated sg() setup = (sg = $pps2)
# pps_time  = @belapsed sg() setup = (sg = $pps)
# pps2_time = @belapsed sg() setup = (sg = $pps2)

# pps_allo = (pps_allo -  pps2_allo)/pps_allo * 100
# pps_time = (pps_time -  pps2_time)/pps_time * 100
# @show pps_allo, pps_time
