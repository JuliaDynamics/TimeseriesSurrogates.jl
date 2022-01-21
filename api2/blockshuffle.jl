using BenchmarkTools, Random

rng = MersenneTwister(1234)
rng2 = MersenneTwister(1234)
n = 5000; a = 0.7; A = 20; σ = 15
x = cumsum(randn(n)) .+ [(1 + a*i) .+ A*sin(2π/10*i) for i = 1:n];
blockshuffle = surrogenerator(x, BlockShuffle(10), rng);
blockshuffle2 = surrogenerator(x, BlockShuffle2(10, shift = true), rng2);
blockshuffle(); @btime sg() setup = (sg = $blockshuffle);
blockshuffle2(); @btime sg() setup = (sg = $blockshuffle2);

# blockshuffle_allo  = @ballocated sg() setup = (sg = $blockshuffle)
# blockshuffle2_allo = @ballocated sg() setup = (sg = $blockshuffle2)
# blockshuffle_time  = @belapsed sg() setup = (sg = $blockshuffle)
# blockshuffle2_time = @belapsed sg() setup = (sg = $blockshuffle2)

# blockshuffle_allo = (blockshuffle_allo -  blockshuffle2_allo)/blockshuffle_allo * 100
# blockshuffle_time = (blockshuffle_time -  blockshuffle2_time)/blockshuffle_time * 100
# @show blockshuffle_allo, blockshuffle_time
