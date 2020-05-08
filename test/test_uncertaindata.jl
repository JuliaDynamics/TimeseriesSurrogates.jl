L = 50
D = UncertainDataset([UncertainValue(Normal, rand(), rand()) for i = 1:L])
V = UncertainValueDataset([UncertainValue(Normal, rand(), rand()) for i = 1:L])
I = UncertainIndexDataset([UncertainValue(Normal, rand(), rand()) for i = 1:L])

@test randomshuffle(D) isa Vector{Float64}
@test randomshuffle(V) isa Vector{Float64}
@test randomshuffle(I) isa Vector{Float64}

@test randomphases(D) isa Vector{Float64}
@test randomphases(V) isa Vector{Float64}
@test randomphases(I) isa Vector{Float64}


@test randomamplitudes(D) isa Vector{Float64}
@test randomamplitudes(V) isa Vector{Float64}
@test randomamplitudes(I) isa Vector{Float64}


@test aaft(D) isa Vector{Float64}
@test aaft(V) isa Vector{Float64}
@test aaft(I) isa Vector{Float64}

@test iaaft(D) isa Vector{Float64}
@test iaaft(V) isa Vector{Float64}
@test iaaft(I) isa Vector{Float64}

method_AAFT = AAFT()
method_IAAFT = IAAFT()
method_RandomShuffle = RandomShuffle()
method_RandomFourier = RandomFourier()

@test surrogate(D, method_AAFT) isa Vector{Float64}
@test surrogate(D, method_IAAFT) isa Vector{Float64}
@test surrogate(D, method_RandomShuffle) isa Vector{Float64}
@test surrogate(D, method_RandomFourier) isa Vector{Float64}

@test surrogate(V, method_AAFT) isa Vector{Float64}
@test surrogate(V, method_IAAFT) isa Vector{Float64}
@test surrogate(V, method_RandomShuffle) isa Vector{Float64}
@test surrogate(V, method_RandomFourier) isa Vector{Float64}

@test surrogate(I, method_AAFT) isa Vector{Float64}
@test surrogate(I, method_IAAFT) isa Vector{Float64}
@test surrogate(I, method_RandomShuffle) isa Vector{Float64}
@test surrogate(I, method_RandomFourier) isa Vector{Float64}