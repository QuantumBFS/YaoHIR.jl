using CompilerPluginTools, YaoLocations

"""
    random_circuit(nbits, ngates [, two_qubits_ratio, t_ratio])

Generate a random quantum circuit of qubit number `nbits` and with gate number `ngates`,
where 2-qubit gate number is of ratio `two_qubits_ratio` and T-gate number of ratio `t_ratio`.
"""
function random_circuit(nbits, ngates, two_qubits_ratio = 0.2, t_ratio = 0.1)
    ir = @make_ircode begin
    end
    c = Chain()
    for _ = 1:ngates
        r = rand()
        if nbits <= 1
            r *= (1 - two_qubits_ratio)
        end
        if r < 1 - (two_qubits_ratio + t_ratio)
            g = rand((X, Z, H, S))
            if g === S
                g = rand((S, S'))
            end
            push!(c.args, Gate(g, Locations(rand(1:nbits))))
        elseif r < 1 - two_qubits_ratio
            g = rand((T, T'))
            push!(c.args, Gate(g, Locations(rand(1:nbits))))
        else
            g = rand((X, Z))
            loc = rand(1:nbits)
            ctrl = rand(1:nbits)
            while ctrl == loc
                ctrl = rand(1:nbits)
            end
            push!(c.args, Ctrl(Gate(g, Locations(loc)), CtrlLocations(ctrl)))
        end
    end
    bir = BlockIR(ir, nbits, c)
    return bir
end

"""
    tcount(c)

Returns the number of non-Clifford gates in circuit `c`. 
"""
tcount(bir::BlockIR) = tcount(bir.circuit)
tcount(c::Chain) = sum(tcount(g) for g in c.args)
tcount(::Routine) = error("T-count for type $T is not defined")
tcount(g::AdjointOperation) = tcount(g.parent)
function tcount(g::Ctrl)
    if length(g.ctrl) == 1 && length(g.gate.locations) == 1
        (g.gate.operation === X || g.gate.operation === Z) && return 0
    end
    return tcount(decompose_zx(g))
end
tcount(g::Gate) = tcount(g.operation) * length(g.locations)
tcount(::IntrinsicRoutine) = 0
tcount(::TGate) = 1
tcount(g::Rz) = (abs(rem2pi(g.θ*4, RoundNearest)) < 1e-10 ? 1 : 0)
tcount(g::Rx) = (abs(rem2pi(g.θ*4, RoundDown)) < 1e-10 ? 1 : 0)
tcount(g::shift) = (abs(rem2pi(g.θ*4, RoundDown)) < 1e-10 ? 1 : 0)
