using YaoHIR
using YaoHIR.IntrinsicOperation

@testset "convert simple qasm file into BlockIR" begin

  qasm = """
  OPENQASM 2.0;
  include "qelib1.inc";
  qreg q0[3];
  creg c0[2];
  h q0[0];
  h q0[1];
  x q0[2];
  h q0[2];
  CX q0[0], q0[2];
  h q0[0];
  measure q0[0] -> c0[0];
  CX q0[1], q0[2];
  h q0[1];
  measure q0[1] -> c0[1];
  """

  circuit = Chain(
    Gate(H, Locations(1)),
    Gate(H, Locations(2)),
    Gate(X, Locations(3)),
    Gate(H, Locations(3)),
    Ctrl(Gate(X, Locations(1)), CtrlLocations(3)),
    Gate(H, Locations(1)),
    Ctrl(Gate(X, Locations(2)), CtrlLocations(3)),
    Gate(H, Locations(2))
  )


  bir = BlockIR(qasm)

  @testset "conversion" begin
    #    @test chain == bir.circuit
  end


  @testset "correct parsing" begin
    bir !== nothing
  end

end

