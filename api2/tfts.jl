using BenchmarkTools, Random

####################################
# TFTS()
####################################
rng = MersenneTwister(1234)
rng2 = MersenneTwister(1234)
n = 1000
x = cos.(range(0, 20π, length = n)) .+ randn(n)*0.05
tfts = surrogenerator(x, TFTS(0.05), rng)
tfts2 = surrogenerator(x, TFTS2(0.05), rng2)
tfts(); tfts2();

tfts_allo  = @ballocated sg() setup = (sg = $tfts)
tfts2_allo = @ballocated sg() setup = (sg = $tfts2)
tfts_time  = @belapsed sg() setup = (sg = $tfts)
tfts2_time = @belapsed sg() setup = (sg = $tfts2)

tfts_allo = (tfts_allo -  tfts2_allo)/tfts_allo * 100
tfts_time = (tfts_time -  tfts2_time)/tfts_time * 100
@show tfts_allo, tfts_time
