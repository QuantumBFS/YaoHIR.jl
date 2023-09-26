using YaoLocations
using MLStyle
using YaoHIR
using YaoHIR.IntrinsicOperation
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

display(X)
display(Rx(1.0))
display(YaoHIR.Operation(X, 2.0))

circ = Chain(
    Gate(X, Locations(1)),
    Core.SSAValue(1),
    Ctrl(Gate(Core.SSAValue(1), Locations(3)), CtrlLocations(2))
)

print(circ)

@test YaoHIR.leaves(circ) == [Gate(X, Locations(1)),
    Core.SSAValue(1),
    Ctrl(Gate(Core.SSAValue(1), Locations(3)), CtrlLocations(2))
]


@testset "test match" begin
    gate = Gate(X, Locations(2))

    @match gate begin
        Gate(op, locs) => begin
            @test op == X
            @test locs == Locations(2)
        end
    end

    ctrl = Ctrl(Gate(X, Locations(2)), CtrlLocations(3))

    @match ctrl begin
        Ctrl(Gate(op, locs), ctrl) => begin
            @test op == X
            @test locs == Locations(2)
            @test ctrl == CtrlLocations(3)
        end
    end
end

@testset "isequal" begin
    circuit1 = Chain(Gate(H, Locations((1, ))), Gate(H, Locations((1, ))))
    circuit2 = Chain(Gate(H, Locations((1, ))), Gate(H, Locations((1, ))))
    @test circuit1 == circuit2
end

include("qasm.jl")
