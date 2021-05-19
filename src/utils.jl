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
tcount(g::Rx) = (abs(rem2pi(g.θ*4, RoundNearest)) < sqrt(eps(typeof(g.θ))) ? 0 : 1)
tcount(g::Ry) = (abs(rem2pi(g.θ*4, RoundNearest)) < sqrt(eps(typeof(g.θ))) ? 0 : 1)
tcount(g::Rz) = (abs(rem2pi(g.θ*4, RoundNearest)) < sqrt(eps(typeof(g.θ))) ? 0 : 1)
tcount(g::shift) = (abs(rem2pi(g.θ*4, RoundNearest)) < sqrt(eps(typeof(g.θ))) ? 0 : 1)
