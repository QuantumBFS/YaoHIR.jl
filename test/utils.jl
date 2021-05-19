using YaoHIR, YaoLocations, Test
using YaoHIR: decompose_zx, tcount

ccz = Ctrl(Gate(YaoHIR.Z, Locations(3)), CtrlLocations((1,2)))
ccx = Ctrl(Gate(YaoHIR.X, Locations(3)), CtrlLocations((1,2)))
@test tcount(ccz) == tcount(ccx) == 7
@test decompose_zx(ccz).args == decompose_zx(Chain(ccz)).args

# 2-qubit gates 
ctrl_ry = Ctrl(Gate(YaoHIR.Ry(π/2), Locations(1)), CtrlLocations(2))
ctrl_ry_zx = decompose_zx(ctrl_ry)
@test ctrl_ry_zx.args[2] == Gate(Rx(π/4), Locations(1)) 
@test tcount(ctrl_ry_zx) == 2
@test tcount(Ctrl(Gate(YaoHIR.S, Locations(1)), CtrlLocations(2))) == 3
@test tcount(Ctrl(Gate(YaoHIR.Y, Locations(1)), CtrlLocations(2))) == 0
@test tcount(Ctrl(Gate(YaoHIR.T, Locations(1)), CtrlLocations(2))) == 3
@test tcount(Ctrl(Gate(shift(π/2), Locations(1)), CtrlLocations(2))) == 3
@test tcount(Ctrl(Gate(Rx(π/2), Locations(1)), CtrlLocations(2))) == 2
@test tcount(Ctrl(Gate(Ry(π/2), Locations(1)), CtrlLocations(2))) == 2
@test tcount(Ctrl(Gate(Rz(π/2), Locations(1)), CtrlLocations(2))) == 2

# 1-qubit gate
@test tcount(Gate(YaoHIR.Y, Locations(1))) == 0
@test tcount(Gate(Ry(π/4), Locations(1))) == 1
@test tcount(Gate(Ry(π/2), Locations(1))) == 0

@test decompose_zx(ccz).args == decompose_zx(decompose_zx(ccz)).args