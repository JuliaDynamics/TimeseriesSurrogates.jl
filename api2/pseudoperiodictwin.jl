using BenchmarkTools, Random

####################################
# PseudoPeriodicTwin()
####################################
rng = MersenneTwister(1234)
rng2 = MersenneTwister(1234)
n = 1000
x = cos.(range(0, 20π, length = n)) .+ randn(n)*0.05
d, τ = 2, 6
ρ = noiseradius(x, d, τ, 0.02:0.02:0.5)
ρ = noiseradius2(x, d, τ, 0.02:0.02:0.5)
ppstwin = surrogenerator(x, PseudoPeriodicTwin(d, τ, ρ), rng);
ppstwin2 = surrogenerator(x, PseudoPeriodicTwin2(d, τ, ρ), rng2);
ppstwin(); ppstwin2();


ppstwin(); @btime sg() setup = (sg = $ppstwin);
ppstwin2(); @btime sg() setup = (sg = $ppstwin2);

# ppstwin_allo  = @ballocated sg() setup = (sg = $ppstwin)
# ppstwin2_allo = @ballocated sg() setup = (sg = $ppstwin2)
# ppstwin_time  = @belapsed sg() setup = (sg = $ppstwin)
# ppstwin2_time = @belapsed sg() setup = (sg = $ppstwin2)

# ppstwin_allo = (ppstwin_allo -  ppstwin2_allo)/ppstwin_allo * 100
# ppstwin_time = (ppstwin_time -  ppstwin2_time)/ppstwin_time * 100
# @show ppstwin_allo, ppstwin_time
