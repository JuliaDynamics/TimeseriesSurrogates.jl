using Base.Test
using TimeseriesSurrogates
ENV["GKSwstype"] = "100"

ts = cumsum(randn(1000))

@testset "Constrained surrogates" begin
    @testset "Random shuffle" begin
        surrogate = randomshuffle(ts)
        @test length(ts) == length(surrogate)
        @test all(sort(ts) .== sort(surrogate))
        @test !all(ts .== surrogate)
    end

    @testset "Random phases" begin
        surrogate = randomphases(ts)
        @test length(ts) == length(surrogate)
        @test !all(ts .== surrogate)
    end

    @testset "Random amplitudes" begin
        surrogate = randomphases(ts)
        @test length(ts) == length(surrogate)
        @test all(ts .!= surrogate)
    end

    @testset "AAFT" begin
        surrogate = aaft(ts)
        @test length(ts) == length(surrogate)
        #@test all(ts .!= surrogate)
        @test all(sort(ts) .== sort(surrogate))
    end

    @testset "IAAFT" begin
        # Single realization
        surrogate = iaaft(ts)
        @test length(ts) == length(surrogate)
        #@test all(ts .!= surrogate)
        @test all(sort(ts) .== sort(surrogate))

        # Storing all realizations during iterations (the last vector contains the final
        # surrogate).
        surrogates = iaaft_iters(ts)
        @test length(ts) == length(surrogates[1])
        #@test all(ts .!= surrogates[end])
        @test all(sort(ts) .== sort(surrogates[end]))
    end

    @testset "WIAAFT" begin
        wiaaft(ts)
    end
end
