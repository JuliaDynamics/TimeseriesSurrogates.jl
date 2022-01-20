using BenchmarkTools, Random

####################################
# CircShift()
####################################
rng = MersenneTwister(1234)
rng2 = MersenneTwister(1234)
x = random_cycles(rng, periods = 90)[1:5000]
cs = surrogenerator(x, CircShift(n), rng); cs(); 
cs2 = surrogenerator(x, CircShift2(n), rng2); cs2();


circs_bt  = @btime sg() setup = (sg = $cs);
circs2_bt = @btime sg() setup = (sg = $cs2);

# circs_allo  = @ballocated sg() setup = (sg = $cs) samples = 100000
# circs2_allo = @ballocated sg() setup = (sg = $cs2) samples = 100000
# circs_time  = @belapsed sg() setup = (sg = $cs) samples = 100000
# circs2_time = @belapsed sg() setup = (sg = $cs2) samples = 100000

# circshift_allo = (circs_allo -  circs2_allo)/circs_allo * 100
# circshift_time = (circs_time -  circs2_time)/circs_time * 100
# @show circshift_allo, circshift_time
