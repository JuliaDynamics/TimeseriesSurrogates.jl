using Test
using TimeseriesSurrogates
ENV["GKSwstype"] = "100"

N = 1000
ts = cumsum(randn(N))
ts_nan = cumsum(randn(N))
ts_nan[1] = NaN
x = cos.(range(0, 20π, length = N)) .+ randn(N)*0.05

@testset "WLS" begin
    wts = WLS()
    wts = WLS(AAFT())
    s = surrogate(x, wts)

    @test length(s) == length(x)
    @test all([s[i] ∈ x for i = 1:N])
end

@testset "Periodic" begin
	pp = PseudoPeriodic(3, 25, 0.05)
	s = surrogate(x, pp)
	@test length(s) == length(ts)
	@test all(s[i] ∈ x for i in 1:N)
	# Perhaps a more advanced test, e.g. that both components have Fourier peak at
	# the same frequency, should be considered.

	#TODO: Test for noiseradius
end

@testset "BlockShuffle" begin
    bs1 = BlockShuffle()
    bs2 = BlockShuffle(4)
    s1 = surrogate(x, bs1)
    s2 = surrogate(x, bs2)

    @test length(s1) == length(x)
    @test length(s2) == length(x)
    @test all([s1[i] ∈ x for i = 1:N])
    @test all([s2[i] ∈ x for i = 1:N])
end

@testset "RandomShuffle" begin
    rs = RandomShuffle()
    s = surrogate(x, rs)

    @test length(s) == length(x)
    @test all([s[i] ∈ x for i = 1:N])
end

@testset "AutoRegressive" begin
	y = TimeseriesSurrogates.AR1(2000, 0.1, 0.5)
    sg = surrogenerator(y, AutoRegressive(1))
	@test 0.4 ≤ abs(sg.init.φ[1]) ≤ 0.6
	s = sg()
    @test length(s) == length(y)
end

@testset "AAFT" begin
    aaft = AAFT()
    s = surrogate(x, aaft)

    @test length(s) == length(x)
    @test all([s[i] ∈ x for i = 1:N])
end

@testset "IAAFT" begin
    iaaft = IAAFT()
    s = surrogate(x, iaaft)

    @test length(s) == length(x)
    @test all([s[i] ∈ x for i = 1:N])
end

@testset "TFTS" begin
    method_preserve_lofreq = TFTS(0.05)
    method_preserve_hifreq = TFTS(-0.05)

    s = surrogate(x, method_preserve_lofreq)
    @test length(s) == length(x)

    s = surrogate(x, method_preserve_hifreq)
    @test length(s) == length(x)

    @test_throws ArgumentError TFTS(0)
end


@testset "TAAFT" begin
    method_preserve_lofreq = TAAFT(0.05)
    method_preserve_hifreq = TAAFT(-0.05)

    s = surrogate(x, method_preserve_lofreq)
    @test length(s) == length(x)
    @test all([s[i] ∈ x for i = 1:N])

    s = surrogate(x, method_preserve_hifreq)
    @test length(s) == length(x)
    @test all([s[i] ∈ x for i = 1:N])

    @test_throws ArgumentError TAAFT(0)
end


@testset "RandomFourier" begin
    @testset "random phases" begin
        phases = true
        rf = RandomFourier(phases)
        s = surrogate(x, rf)

        @test length(s) == length(x)
    end

    @testset "random amplitudes" begin
        phases = false
        rf = RandomFourier(phases)
        s = surrogate(x, rf)

        @test length(s) == length(x)
    end
end

@testset "Circ/Cycle shuffle" begin
	x = random_cycles()
	s = surrogate(x, CycleShuffle())
	for a in s
		@test a ∈ x
	end
	s = surrogate(x, CircShift(1:length(x)))
	for a in s
		@test a ∈ x
	end
end

using DelayEmbeddings
@testset "ShufleDims" begin
	X = Dataset(rand(100, 3))
	Y = surrogate(X, ShuffleDimensions())
	for i in 1:100
		@test sort(X[i]) == sort(Y[i])
	end
end


#=
@testset "IAAFT" begin
    # With pre-planning
    method = IAAFT(ts)
    surr = surrogate(ts, method)
    @test length(ts) == length(surr)
    @test all(sort(ts) .== sort(surr))

    # Without pre-planning
    method = IAAFT()
    surr = surrogate(ts, method)
    @test length(ts) == length(surr)
    @test all(sort(ts) .== sort(surr))
end
=#
