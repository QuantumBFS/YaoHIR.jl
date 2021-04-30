using YaoLocations
using MLStyle
using YaoHIR
using Test

@testset "YaoHIR.jl" begin
    # Write your tests here.
end
using YaoHIR: intrinsic_m
intrinsic_m(:X)
intrinsic_m(:(Rx(theta::T) where {T <: Real}))

Chain([Gate(YaoHIR.X, Locations(1)), ])