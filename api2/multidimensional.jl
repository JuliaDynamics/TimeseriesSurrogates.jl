using BenchmarkTools, Random, DelayEmbeddings

####################################
# Multidimensional()
####################################
rng = MersenneTwister(1234)
rng2 = MersenneTwister(1234)
n = 1000
x = cos.(range(0, 20π, length = n)) .+ randn(n)*0.05
y = .-(cos.(range(0, 20π, length = n)) .+ randn(n)*0.05)
z = (cos.(range(0, 20π, length = n)) .+ randn(n)*0.05) .* rand(n)
w = (cos.(range(0, 20π, length = n)) .+ randn(n)*0.05) .* rand(n)

D = Dataset(x, y, z, w)
md = surrogenerator(D, ShuffleDimensions(), rng)
md2 = surrogenerator(D, ShuffleDimensions2(), rng2)
md(); md2();

md_allo  = @ballocated sg() setup = (sg = $md)
md2_allo = @ballocated sg() setup = (sg = $md2)
md_time  = @belapsed sg() setup = (sg = $md)
md2_time = @belapsed sg() setup = (sg = $md2)

multidim_allo = (md_allo -  md2_allo)/md_allo * 100
multidim_time = (md_time -  md2_time)/md_time * 100
@show multidim_allo, multidim_time
