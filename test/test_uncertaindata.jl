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