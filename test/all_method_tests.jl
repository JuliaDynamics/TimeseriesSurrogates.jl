using Test
using TimeseriesSurrogates
using TimeseriesSurrogates.AbstractFFTs
using TimeseriesSurrogates.Statistics
using TimeseriesSurrogates.Random
ENV["GKSwstype"] = "100"

N = 500
ts = cumsum(randn(N))
ts_nan = cumsum(randn(N))
ts_nan[1] = NaN
x = cos.(range(0, 20π, length = N)) .+ randn(N)*0.05

@testset "LombScargle" begin
    t = sort((0:N-1) + rand(N))
    tol = 10
    ls = IrregularLombScargle(t, tol = 10, n_total = 20000, n_acc = 5000)

    s = surrogate(x, ls)

    @test all(sort(s) .== sort(x))
end

@testset "WLS" begin
    wts_norescale = WLS(AAFT(), rescale = false)
    wts_rescale = WLS(AAFT())

    s_norescale = surrogate(x, wts_norescale)
    s_rescale = surrogate(x, wts_rescale)
    @test length(s_norescale) == length(x)
    @test length(s_rescale) == length(x)

    # If rescaling, the surrogate will have the same values as the original
    @test sort(x) ≈ sort(s_rescale)

end

@testset "PartialRandomization" begin
    Random.seed!(32)

    # Absolute randomization, Ortega
    pr = PartialRandomization(0.2)
    s = surrogate(x, pr)
    @test length(s) == length(x)
    @test_throws AssertionError PartialRandomization(-0.01)
    @test_throws AssertionError PartialRandomization(1.01)

    pr = PartialRandomization(0.0)
    s = surrogate(x, pr)
    @test s |> rfft .|> angle |> std |> ≈(0, atol=1e-9)

    pr = PartialRandomization(1.0)
    s = surrogate(x, pr)
    @test s |> rfft .|> angle |> std |> ≈(π/sqrt(3), atol=1e-1)

    # Relative randomization
    pr = PartialRandomization(0.2, :relative)
    @test_nowarn s = surrogate(x, pr)
    @test length(s) == length(x)
    pr = PartialRandomization(0.0, :relative)
    @test_nowarn s = surrogate(x, pr)
    @test s |> ≈(x, rtol=1e-2) # No randomization, so the surrogate should be close to the original
    pr = PartialRandomization(1.0, :relative)
    s = surrogate(cos.(0:0.1:1000).^2, pr)
    @test s |> rfft .|> angle |> std |> ≈(π/sqrt(3), atol=1e-1)

    # Randomization based on the spectrum
    pr = PartialRandomization(0.2, :spectrum)
    @test_nowarn s = surrogate(x, pr)
    pr = PartialRandomization(0.0, :spectrum)
    @test_nowarn s = surrogate(x, pr)
    @test s |> ≈(x, rtol=1e-2)
    pr = PartialRandomization(1.0, :spectrum)
    s = surrogate(cos.(0:0.1:1000).^2, pr)
    @test s |> rfft .|> angle |> std |> ≈(π/sqrt(3), atol=1e-1)
end

@testset "PartialRandomizationAAFT" begin
    praaft = PartialRandomizationAAFT(0.5)
    s = surrogate(x, praaft)

    @test length(s) == length(x)
    @test sort(x) ≈ sort(s)

    @test_throws AssertionError PartialRandomizationAAFT(-0.01)
    @test_throws AssertionError PartialRandomizationAAFT(1.01)
end

@testset "RandomCascade" begin
    randomcascade = RandomCascade()
    s = surrogate(x, randomcascade)

    @test length(s) == length(x)

    @testset "Padding modes" begin
        x̃ = zeros(2^(TimeseriesSurrogates.ndyadicscales(length(x)) + 1))
        TimeseriesSurrogates.pad!(x̃, x, "zeros")
        @test all(x̃[length(x)+1:end] .== 0.0)
        TimeseriesSurrogates.pad!(x̃, x, "constant")
        @test all(x̃[length(x)+1:end] .== x[end])
        TimeseriesSurrogates.pad!(x̃, x, "linear")
        dx = x[end] - x[end-1]
        for i = length(x)+1:length(x̃)
            @test x̃[i] - x̃[i-1] ≈ dx
        end

        @test_throws ArgumentError surrogate(x, RandomCascade(; paddingmode="ones"))
    end
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

@testset "PeriodicTwin" begin
    # A better test based on recurrence plots should be considered.
    d, τ = 2, 6
    δ = 0.2
    ρ = noiseradius(x, d, τ, 0.02:0.02:0.5)
    method = PseudoPeriodicTwin(d, τ, δ, ρ)

    sg = surrogenerator(x, method)
    s = sg()[:, 1]
    @test length(s) == length(ts)
    @test all(s[i] ∈ x for i in 1:N)
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
	y = TimeseriesSurrogates.AR1(; n_steps = 2000, x₀ = 0.1, k = 0.5)
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

@testset "TFTDAAFT" begin
    tftdaaft = TFTDAAFT(0.03)
    s = surrogate(x, tftdaaft)
    @test length(s) == length(x)
    @test sort(x) ≈ sort(s)
    @test_throws ArgumentError TFTD(0)
    @test_throws ArgumentError TFTD(1.2)
end

@testset "TFTDIAAFT" begin
    tftdiaaft = TFTDAAFT(0.05)
    s = surrogate(x, tftdiaaft)
    @test length(s) == length(x)
    @test sort(x) ≈ sort(s)
    @test_throws ArgumentError TFTD(0)
    @test_throws ArgumentError TFTD(1.2)
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

@testset "TFTDRandomFourier" begin
    @testset "random phases" begin
        phases = true
        rf = TFTDRandomFourier(phases)
        s = surrogate(x, rf)

        @test length(s) == length(x)
    end

    @testset "random amplitudes" begin
        phases = false
        rf = TFTDRandomFourier(phases)
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
	X = StateSpaceSet(rand(100, 3))
	Y = surrogate(X, ShuffleDimensions())
	for i in 1:100
		@test sort(X[i]) == sort(Y[i])
	end
end
