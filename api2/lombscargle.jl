using BenchmarkTools, Random

####################################
# IrregularLombScargle()
####################################
rng = MersenneTwister(1234)
rng2 = MersenneTwister(1234)
n = 200
x = AR1()[1:n]
t = collect(1:n) .+ rand(n)
lomb = surrogenerator(x, IrregularLombScargle(t, n_total = 10000, n_acc = 2000), rng);
lomb2 = surrogenerator(x, IrregularLombScargle2(t, n_total = 10000, n_acc = 2000), rng2);
lomb(); lomb2();

lomb(); @btime sg() setup = (sg = $lomb)
lomb2(); @btime sg() setup = (sg = $lomb2)

# lomb_allo  = @ballocated sg() setup = (sg = $lomb)
# lomb2_allo = @ballocated sg() setup = (sg = $lomb2)
# lomb_time  = @belapsed sg() setup = (sg = $lomb)
# lomb2_time = @belapsed sg() setup = (sg = $lomb2)

# lomb_allo = (lomb_allo -  lomb2_allo)/lomb_allo * 100
# lomb_time = (lomb_time -  lomb2_time)/lomb_time * 100
# @show lomb_allo, lomb_time
# Old: 5.062 s (9142792 allocations: 5.02 GiB)
# New: 2.510 s (4541688 allocations: 2.51 GiB)
# New: 2.506 s (4531694 allocations: 2.51 GiB)
# 2.489 s (4531684 allocations: 2.51 GiB)