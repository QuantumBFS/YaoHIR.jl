module YaoHIRExt 

using YaoHIR, YaoLocations
using YaoHIR.IntrinsicOperation
using MLStyle
using OpenQASM
using OpenQASM.Types: Instruction, CXGate, Measure, Reset, MainProgram, Include, RegDecl, ASTNode
using Core.Compiler: IRCode

function YaoHIR.BlockIR(ast::MainProgram) 
  convert_to_blockir(ast::MainProgram)
end
function YaoHIR.BlockIR(qasm::String) 
  convert_to_blockir(OpenQASM.parse(qasm)::MainProgram)
end

qarg_address(i::Instruction) = Locations(parse(Int, i.qargs[1].address.str) + 1)
qarg_address(i::CXGate) = Locations(parse(Int, i.qarg.address.str) + 1)
#qarg_address(i::CZGate) = Locations(parse(Int, i.qarg.address.str) + 1)
ctrl_address(i::ASTNode) = Locations(parse(Int, i.ctrl.address.str) + 1)


push_prog!(circ::Chain, prog::Any) = prog !== nothing && push!(circ.args, prog)

function convert_to_blockir(ast::MainProgram)
  qubits = sum([parse(Int, m.size.str) for m in ast.prog if m isa RegDecl && m.type.str == "qreg"])
  ir = IRCode()
  chain = Chain()
  [push_prog!(chain, prog_to_gate(prog)) for prog in ast.prog]
  BlockIR(ir, qubits, chain)
end


function instruction_to_gate(i::Instruction)
  @switch i.name begin
    @case "z"
    Gate(Z, qarg_address(i))
    @case "x"
    Gate(X, qarg_address(i))
    @case "h"
    Gate(H, qarg_address(i))
    @case "s"
    Gate(S, qarg_address(i))
    @case "sdg"
    Gate(AdjointOperation(S), qarg_address(i))
    @case "t"
    Gate(S, qarg_address(i))
    @case "tdg"
    Gate(AdjointOperation(T), qarg_address(i))
    @case "rx"
    error("Gate $i not yet implemented")
    @case "rx"
    error("Gate $i not yet implemented")
    @case "shift"
    error("Gate $i not yet implemented")
    @case "id"
    nothing
    @case _
    error("Gate $i not supported")
  end
end

function prog_to_gate(a::Any)
  @match a begin
    i::Include => nothing
    r::RegDecl => nothing
    inst::Instruction => instruction_to_gate(inst)
    cx::CXGate => Ctrl(Gate(X,
        Locations(qarg_address(cx))),
      CtrlLocations(ctrl_address(cx)))

#    cz::CZGate => Ctrl(Gate(Z,
#        Locations(qarg_address(cz))),
#      CtrlLocations(ctrl_address(cz)))
    m::Measure => nothing
    r::Reset => error("only unitaries are supported, please use the function reconstruct_unitaries from the package QuantumCircuitEquivalence.jl")
  end
end

end
