module TestIntrinsic
using YaoHIR: @intrinsic

@intrinsic X
@intrinsic R(theta::T) where {T <: Real}
@intrinsic SWAP

end

@testset "instrinic" begin

  @test YaoHIR.routine_name(TestIntrinsic.X) == :X
  @test YaoHIR.routine_name(TestIntrinsic.R(1.0)) == :R
  @test TestIntrinsic.R(1.0).theta == 1.0

end
