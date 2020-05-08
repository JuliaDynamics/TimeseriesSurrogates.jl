using Test
using TimeseriesSurrogates
ENV["GKSwstype"] = "100"

N = 1000
ts = cumsum(randn(N))
ts_nan = cumsum(randn(N))
ts_nan[1] = NaN
x = cos.(range(0, 20π, length = N)) .+ randn(N)*0.05

@testset "Periodic" begin
	pp = PseudoPeriodic(3, 25, 0.05)
	s = surrogate(x, pp)
	@test length(s) == length(ts)
	@test all(s[i] ∈ x for i in 1:N)
	# Perhaps a more advanced test, e.g. that both components have Fourier peak at
	# the same frequency, should be considered.

	#TODO: Test for noiseradius
end

@testset "Constrained surrogates" begin
    @testset "Random shuffle" begin
        surr = randomshuffle(ts)
        @test length(ts) == length(surr)
        @test all(sort(ts) .== sort(surr))
        @test !all(ts .== surr)
    end

    @testset "Random phases" begin
        surr = randomphases(ts)
        @test length(ts) == length(surr)
        @test !all(ts .== surr)
    end

    @testset "Random amplitudes" begin
        surr = randomphases(ts)
        @test length(ts) == length(surr)
        @test all(ts .!= surr)
    end

    @testset "AAFT" begin
        surr = aaft(ts)
        @test length(ts) == length(surr)
        @test all(sort(ts) .== sort(surr))
	@test_throws DomainError aaft(ts_nan)
    end

    @testset "IAAFT" begin
        # Single realization
        surr = iaaft(ts)
        @test length(ts) == length(surr)
        @test all(sort(ts) .== sort(surr))

        # Storing all realizations during iterations (the last vector contains the final
        # surrogate).
        surrs = TimeseriesSurrogates.iaaft_iters(ts)
        @test length(ts) == length(surrs[1])
        @test all(sort(ts) .== sort(surrs[end]))
	@test_throws DomainError iaaft(ts_nan)
    end

    @testset "WIAAFT" begin
        wiaaft(ts)
    end
end

@testset "New API" begin
    @testset "Random shuffle" begin
        method = RandomShuffle()
        surr = surrogate(ts, method)
        @test length(ts) == length(surr)
        @test all(sort(ts) .== sort(surr))
        @test !all(ts .== surr)

    end

    @testset "Random phases" begin
        # With pre-planning
        method = RandomFourier(ts, true)
        surr = surrogate(ts, method)
        @test length(ts) == length(surr)
        @test !all(ts .== surr)

        # Without pre-planning
        method = RandomFourier(true)
        surr = surrogate(ts, method)
        @test length(ts) == length(surr)
        @test !all(ts .== surr)
    end

    @testset "Random amplitudes" begin
       # With pre-planning
       method = RandomFourier(ts, false)
       surr = surrogate(ts, method)
       @test length(ts) == length(surr)
       @test !all(ts .== surr)

       # Without pre-planning
       method = RandomFourier(false)
       surr = surrogate(ts, method)
       @test length(ts) == length(surr)
       @test !all(ts .== surr)
    end

    @testset "AAFT" begin
        # With pre-planning
        method = AAFT(ts)
        surr = surrogate(ts, method)
        @test length(ts) == length(surr)
        @test all(sort(ts) .== sort(surr))

        # Without pre-planning
        method = AAFT()
        surr = surrogate(ts, method)
        @test length(ts) == length(surr)
        @test all(sort(ts) .== sort(surr))
    end

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

    @testset "WIAAFT" begin
        wiaaft(ts)
    end
end
