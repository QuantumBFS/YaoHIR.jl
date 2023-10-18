using YaoHIR
using YaoHIR.IntrinsicOperation
using OpenQASM

@testset "convert qasm" begin

  bir = BlockIR("""
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
  """)

  @testset "correct parsing" begin
    bir !== nothing
  end

  chain = Chain(
                Gate(H, Locations(1)), 
                Gate(H, Locations(2)), 
                Gate(X, Locations(3)),
                Gate(H, Locations(3)), 
                Ctrl(Gate(X, Locations(3)), CtrlLocations(1)),
                Gate(H, Locations(1)), 
                Ctrl(Gate(X, Locations(3)), CtrlLocations(2)), 
                Gate(H, Locations(2))
               )

  @testset "conversion" begin
    @test chain == bir.circuit
  end


@testset "parse DJ-NAND" begin
  bv = BlockIR("""
  OPENQASM 2.0;
  include "qelib1.inc";
  qreg q[3];
  creg c[2];
  h q[0];
  h q[1];
  x q[2];
  h q[2];
  x q[2];
  h q[2];
  cx q[1],q[2];
  tdg q[2];
  cx q[0],q[2];
  t q[2];
  cx q[1],q[2];
  t q[1];
  tdg q[2];
  cx q[0],q[2];
  cx q[0],q[1];
  t q[0];
  tdg q[1];
  cx q[0],q[1];
  h q[0];
  h q[1];
  t q[2];
  h q[2];
  measure q[0] -> c[0];
  measure q[1] -> c[1];
  """)


  bv_re = BlockIR("""
  OPENQASM 2.0;
  include "qelib1.inc";
  qreg q[3];
  creg c1[1];
  creg c2[1];
  h q[1];
  t q[1];
  x q[2];
  h q[2];
  x q[2];
  h q[2];
  t q[2];
  CX q[1], q[2];
  tdg q[2];
  CX q[1], q[2];
  h q[1];
  h q[2];
  h q[2];
  t q[2];
  h q[0];
  t q[0];
  CX q[0], q[2];
  tdg q[2];
  CX q[0], q[2];
  CX q[1], q[0];
  tdg q[0];
  tdg q[2];
  CX q[0], q[2];
  t q[2];
  CX q[0], q[2];
  CX q[1], q[0];
  h q[0];
  h q[2];
  measure q[0] -> c2[0];
  measure q[1] -> c1[0];""")

  @testset "correct parsing" begin
    @test bv !== nothing
  end

  @testset "convert into BlockIR" begin
    @test bv_re !== nothing

  end

end

  @testset "dj 3" begin
  dj3 = BlockIR("""
  OPENQASM 2.0;
  include "qelib1.inc";
  
  qreg q[3];
  creg c[2];
  h q[0];
  h q[1];
  x q[2];
  x q[0];
  x q[1];
  h q[2];
  cx q[0],q[2];
  x q[0];
  cx q[1],q[2];
  h q[0];
  x q[1];
  h q[1];
  """)

  chain = Chain(Gate(H, Locations(1)), 
                Gate(H, Locations(2)), 
                Gate(X, Locations(3)), 
                Gate(X, Locations(1)), 
                Gate(X, Locations(2)), 
                Gate(H, Locations(3)), 
                Ctrl(Gate(X, Locations(3)), 
                CtrlLocations(1)), 
                Gate(X, Locations(1)), 
                Ctrl(Gate(X, Locations(3)), 
                CtrlLocations(2)), 
                Gate(H, Locations(1)), 
                Gate(X, Locations(2)), 
                Gate(H, Locations(2)))

@test dj3.circuit == chain 
# FIXME should an empty IR print '1 ─     return nothing' ? 
# print(dj3)

end

end
