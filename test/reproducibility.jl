using Random
N = 500
ts = cumsum(randn(N))
ts_nan = cumsum(randn(N))
ts_nan[1] = NaN
x = cos.(range(0, 20π, length = N)) .+ randn(N)*0.05

all_conceivable_methods = [
    WLS()
    WLS(AAFT())
    PseudoPeriodic(3, 25, 0.05)
    BlockShuffle()
    BlockShuffle(4)
    RandomShuffle()
    AutoRegressive(1)
    AAFT()
    IAAFT()
    TFTS(0.05)
    TFTS(-0.05)
    TAAFT(0.05)
    TAAFT(-0.05)
    RandomFourier(true)
    RandomFourier(false)
    CycleShuffle()
]

methodnames = [string(nameof(typeof(x))) for x in all_conceivable_methods]

@testset "Reproducibility (rng)" begin
    @testset "$n" for (i, n) in enumerate(methodnames)
        method = all_conceivable_methods[i]
        rng = Random.MersenneTwister(1234)
        y = surrogate(x, method, rng)
        rng = Random.MersenneTwister(1234)
        z = surrogate(x, method, rng)
        @test y == z
    end
end