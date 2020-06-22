using Test
using TimeseriesSurrogates

dt = π/20
x = Float64[]

for i in 1:10 # 10 periods
    f = rand()*1.0 + 0.8
    T = 2π/f
    t = 0:dt:T
    append!(x, sin.(f .* t))
end

N = length(x)
x .+= randn(N)/20
