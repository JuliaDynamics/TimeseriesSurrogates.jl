using BenchmarkTools , Random

x =rand(10) #random_cycles(periods = 1)
rs = surrogenerator(x, RandomShuffle(), MersenneTwister(1234))
rs2 = surrogenerator(x, RandomShuffle2(), MersenneTwister(1234))
rs(); rs2();

# x = @btime sg() setup = (sg = $rs);
# y = @btime sg() setup = (sg = $rs2);
# @show all(x .== y)
# nothing

