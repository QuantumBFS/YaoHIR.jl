"""
    decompose_zx(c)

Decompose `c` into terms of Z- and X-basis.
"""
decompose_zx(::TT) where TT = error("`decompose_zx` is not defined for type $TT")
decompose_zx(bir::BlockIR) = BlockIR(bir.parent, bir.nqubits, decompose_zx(bir.circuit))
function decompose_zx(c::Chain)
    new_chain = Chain()
    for g in c.args
        cg = decompose_zx(g)
        if cg isa Chain
            for gg in cg.args
                push!(new_chain.args, gg)
            end
        else
            push!(new_chain.args, cg)
        end
    end
    return new_chain
end
decompose_zx(a::AdjointOperation) = AdjointOperation(decompose_zx(a.parent))
function decompose_zx(g::Gate)
    op = g.operation
    loc = g.locations
    @switch op begin
        @case ::YGate
            return Chain(Gate(YaoHIR.S', loc), Gate(YaoHIR.X, loc), Gate(YaoHIR.S, loc))
        @case ::Ry
            return Chain(Gate(YaoHIR.S', loc), Gate(Rx(theta), loc), Gate(YaoHIR.S, loc))
        @case _
            return g
    end
end
function decompose_zx(cg::Ctrl)
    ctrl = cg.ctrl
    g = cg.gate
    if length(ctrl) == 1
        if length(g.locations) == 1
            @switch g begin
                @case Gate(::YGate, loc)
                    return Chain(Gate(YaoHIR.S', loc), Ctrl(Gate(YaoHIR.X, loc), ctrl), Gate(YaoHIR.S, loc))
                @case Gate(::SGate, loc)
                    return Chain(
                        Gate(YaoHIR.T, Locations(YaoLocations.plain(ctrl))), 
                        Gate(YaoHIR.T, loc), 
                        Ctrl(Gate(YaoHIR.X, loc), ctrl), 
                        Gate(YaoHIR.T', loc), 
                        Ctrl(Gate(YaoHIR.X, loc), ctrl), 
                    )
                @case Gate(::TGate, loc)
                    return Chain(
                        Gate(shift(π/8), Locations(YaoLocations.plain(ctrl))), 
                        Gate(shift(π/8), loc), 
                        Ctrl(Gate(YaoHIR.X, loc), ctrl), 
                        Gate(shift(-π/8), loc), 
                        Ctrl(Gate(YaoHIR.X, loc), ctrl), 
                    )
                @case Gate(shift(θ), loc)
                    return Chain(
                        Gate(shift(θ/2), Locations(YaoLocations.plain(ctrl))), 
                        Gate(shift(θ/2), loc), 
                        Ctrl(Gate(YaoHIR.X, loc), ctrl), 
                        Gate(shift(-θ/2), loc), 
                        Ctrl(Gate(YaoHIR.X, loc), ctrl), 
                    )
                @case Gate(Rx(θ), loc)
                    return Chain(
                        Gate(Rx(θ/2), loc), 
                        Ctrl(Gate(YaoHIR.X, loc), ctrl), 
                        Gate(Rx(-θ/2), loc), 
                        Ctrl(Gate(YaoHIR.X, loc), ctrl), 
                    )
                @case Gate(Ry(θ), loc)
                    return Chain(
                        Gate(Ry(θ/2), loc), 
                        Ctrl(Gate(YaoHIR.X, loc), ctrl), 
                        Gate(Ry(-θ/2), loc), 
                        Ctrl(Gate(YaoHIR.X, loc), ctrl), 
                    )
                @case Gate(Rz(θ), loc)
                    return Chain(
                        Gate(Rz(θ/2), loc), 
                        Ctrl(Gate(YaoHIR.X, loc), ctrl), 
                        Gate(Rz(-θ/2), loc), 
                        Ctrl(Gate(YaoHIR.X, loc), ctrl), 
                    )
                @case Gate(AdjointOperation(op), loc)
                    return decompose_zx(Ctrl(Gate(op, loc), ctrl))'
                @case Gate(::XGate, loc)
                    return cg
                @case Gate(::ZGate, loc)
                    return cg
                @case _
            end
        end
    elseif length(ctrl) == 2
        a, b = YaoLocations.plain(ctrl)
        if length(g.locations) == 1
            @switch g begin
                @case Gate(::XGate, loc)
                    return Chain(Gate(YaoHIR.H, loc),
                        Ctrl(Gate(YaoHIR.X, Locations(YaoLocations.plain(loc))), CtrlLocations(b)),
                        Gate(YaoHIR.T', loc),
                        Ctrl(Gate(YaoHIR.X, Locations(YaoLocations.plain(loc))), CtrlLocations(a)),
                        Gate(YaoHIR.T, loc),
                        Ctrl(Gate(YaoHIR.X, Locations(YaoLocations.plain(loc))), CtrlLocations(b)),
                        Gate(YaoHIR.T', loc),
                        Ctrl(Gate(YaoHIR.X, Locations(YaoLocations.plain(loc))), CtrlLocations(a)),
                        Gate(YaoHIR.T, loc),
                        Gate(YaoHIR.T, b),
                        Gate(YaoHIR.H, loc),
                        Ctrl(Gate(YaoHIR.X, Locations(b)), CtrlLocations(a)),
                        Gate(YaoHIR.T, a),
                        Gate(YaoHIR.T', b),
                        Ctrl(Gate(YaoHIR.X, Locations(b)), CtrlLocations(a)),
                    )
                @case Gate(::ZGate, loc)
                    return Chain(Ctrl(Gate(YaoHIR.X, Locations(YaoLocations.plain(loc))), CtrlLocations(b)),
                        Gate(YaoHIR.T', loc),
                        Ctrl(Gate(YaoHIR.X, Locations(YaoLocations.plain(loc))), CtrlLocations(a)),
                        Gate(YaoHIR.T, loc),
                        Ctrl(Gate(YaoHIR.X, Locations(YaoLocations.plain(loc))), CtrlLocations(b)),
                        Gate(YaoHIR.T', loc),
                        Ctrl(Gate(YaoHIR.X, Locations(YaoLocations.plain(loc))), CtrlLocations(a)),
                        Gate(YaoHIR.T, loc),
                        Gate(YaoHIR.T, b),
                        Gate(YaoHIR.H, loc),
                        Ctrl(Gate(YaoHIR.X, Locations(b)), CtrlLocations(a)),
                        Gate(YaoHIR.T, a),
                        Gate(YaoHIR.T', b),
                        Ctrl(Gate(YaoHIR.X, Locations(b)), CtrlLocations(a)),
                        Gate(YaoHIR.H, loc),
                    )
            end
        end
    end
    error("`decompose_zx` is not defined for $cg")
end
