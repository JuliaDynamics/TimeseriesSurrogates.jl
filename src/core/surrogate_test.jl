abstract type AbstractSurrogateTest end

struct SurrogateTest{F<:Function, S<:Surrogate, R<:AbstractRNG} <: AbstractSurrogateTest
    f::F
    s::S
    rng::R
    n::Int
    # fields that are filled whenever a function is called
    # for pretty printing or for keeping track of results
    vals::Vector{X}
    rval::RefValue{X}
end

function SurrogateTest(f::F, s::S; kwargs...) where {F<:Function, S<:Surrogate}
    # code
end

function StatsAPI.pvalue(test::SurrogateTest, x::Input; tail = :right)
    fill_surrogate_test!(test, x)
    # estimate pvalue from res.vals
    p = whatever
    return p
end
