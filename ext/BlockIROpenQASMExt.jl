module BlockIROpenQASMExt

using YaoHIR, YaoLocations
using YaoHIR.IntrinsicOperation
using MLStyle
using OpenQASM
using OpenQASM.Types: Instruction, CXGate, CZGate, Measure, Reset, MainProgram, Include, RegDecl, ASTNode
using CompilerPluginTools

YaoHIR.BlockIR(ast::MainProgram) = convert_to_blockir(ast::MainProgram)
YaoHIR.BlockIR(qasm::String) = convert_to_blockir(OpenQASM.parse(qasm)::MainProgram)

qarg_address(i::Instruction) = Locations(parse(Int, i.qargs[1].address.str) + 1)
qarg_address(i::CXGate) = Locations(parse(Int, i.qarg.address.str) + 1)
qarg_address(i::CZGate) = Locations(parse(Int, i.qarg.address.str) + 1)
ctrl_address(i::ASTNode) = Locations(parse(Int, i.ctrl.address.str) + 1)


push_prog!(circ::Chain, prog::Any) = prog !== nothing && push!(circ.args, prog)

function convert_to_blockir(ast::MainProgram)
  qubits = qubits = sum([parse(Int, m.size.str) for m in ast.prog if m isa RegDecl && m.type.str == "qreg"])
  ir = @make_ircode begin end
  chain = Chain()
  [push_prog!(chain, prog_to_gate(prog)) for prog in ast.prog]
  BlockIR(ir, qubits, chain)
end


function instruction_to_gate(i::Instruction)
  @switch i.name begin
    @case "z"
    Gate(IntrinsicOperation.Z, qarg_address(i))
    @case "x"
    Gate(IntrinsicOperation.X, qarg_address(i))
    @case "h"
    Gate(IntrinsicOperation.H, qarg_address(i))
    @case "s"
    Gate(IntrinsicOperation.S, qarg_address(i))
    @case "sdag"
    Gate(IntrinsicOperation.S, qarg_address(i))
    @case "t"
    Gate(IntrinsicOperation.R, qarg_address(i))
    @case "tdag"
    Gate(IntrinsicOperation.t, qarg_address(i))
    @case "rx"
    error("Gate $i not yet implemented")
    @case "rx"
    error("Gate $i not yet implemented")
    @case "shift"
    error("Gate $i not yet implemented")

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
        Locations(ctrl_address(cx))),
      CtrlLocations(qarg_address(cx)))

    cz::CZGate => Ctrl(Gate(Z,
        Locations(qarg_address(cz))),
      CtrlLocations(ctrl_address(cz)))
    m::Measure => nothing
    r::Reset => error("Only unitaries are supported, please use the convert function")
  end
end

end
