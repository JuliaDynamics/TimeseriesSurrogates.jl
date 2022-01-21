using BenchmarkTools, Random

rng = MersenneTwister(1234)
rng2 = MersenneTwister(1234)
n = 5000; a = 0.7; A = 20; σ = 15
x = cumsum(randn(n)) .+ [(1 + a*i) .+ A*sin(2π/10*i) for i = 1:n];
ar = surrogenerator(x, AutoRegressive(1), rng);
ar2 = surrogenerator(x, AutoRegressive2(1), rng2);
ar(); @btime sg() setup = (sg = $ar);
ar2(); @btime sg() setup = (sg = $ar2);
