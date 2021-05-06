using YaoLocations
using MLStyle
using YaoHIR
using Test

module TestIntrinsic
using YaoHIR: @intrinsic

@intrinsic X
@intrinsic R(theta::T) where {T <: Real}

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

print(circ_1)
