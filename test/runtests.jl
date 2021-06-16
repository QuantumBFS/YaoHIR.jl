using YaoLocations
using MLStyle
using YaoHIR
using Test

module TestIntrinsic
using YaoHIR: @intrinsic

@intrinsic X
@intrinsic R(theta::T) where {T <: Real}
@intrinsic SWAP

end

@test YaoHIR.routine_name(TestIntrinsic.X) == :X
@test YaoHIR.routine_name(TestIntrinsic.R(1.0)) == :R
@test TestIntrinsic.R(1.0).theta == 1.0

display(YaoHIR.X)
display(YaoHIR.Rx(1.0))
display(YaoHIR.Operation(YaoHIR.X, 2.0))

circ = Chain(
    Gate(YaoHIR.X, Locations(1)),
    Core.SSAValue(1),
    Ctrl(Gate(Core.SSAValue(1), Locations(3)), CtrlLocations(2))
)

println(circ)

@test YaoHIR.leaves(circ) == [Gate(YaoHIR.X, Locations(1)),
    Core.SSAValue(1),
    Ctrl(Gate(Core.SSAValue(1), Locations(3)), CtrlLocations(2))
]


@testset "test match" begin
    gate = Gate(YaoHIR.X, Locations(2))

    @match gate begin
        Gate(op, locs) => begin
            @test op == YaoHIR.X
            @test locs == Locations(2)
        end
    end

    ctrl = Ctrl(Gate(YaoHIR.X, Locations(2)), CtrlLocations(3))

    @match ctrl begin
        Ctrl(Gate(op, locs), ctrl) => begin
            @test op == YaoHIR.X
            @test locs == Locations(2)
            @test ctrl == CtrlLocations(3)
        end
    end
end

@testset "utils.jl" begin
    include("utils.jl")
end
