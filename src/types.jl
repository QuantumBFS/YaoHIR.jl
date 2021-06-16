"""
    GenericRoutine{name} <: Function

A `GenericRoutine` cannot be directly execute on a quantum
device. It is a Julia `Function` that returns `Operation`,
and `Operation` can be executed on quanutm device.

!!! note
    An instance of `GenericRoutine` should be treated like
    `Function`.
"""
abstract type GenericRoutine{name} <: Function end

"""
    abstract type Routine end

This defines operations that one can execute on a quantum device.
"""
abstract type Routine end

"""
    abstract type IntrinsicRoutine <: Routine end

`IntrinsicRoutine` are the routine that can be executed
by the compile target that is pre-defined in the compiler.
"""
abstract type IntrinsicRoutine <: Routine end

"""
    Operation{P, Args} <: Routine

An `Operation` is a user defined composite routine
that can be called in other `Operation` or execute
on target device.
"""
struct Operation{P,Args} <: Routine
    parent::P
    args::Args
end

"""
    AdjointOperation{P} <: Routine

An `AdjointOperation` is the adjoint of another
`Routine`.
"""
struct AdjointOperation{P} <: Routine
    parent::P
end

Base.adjoint(x::Routine) = AdjointOperation(x)
Base.adjoint(x::AdjointOperation) = x.parent

routine_name(::Type) = nothing
routine_name(x) = routine_name(typeof(x))
routine_name(::Type{<:GenericRoutine{name}}) where {name} = name
routine_name(::Type{T}) where {T<:IntrinsicRoutine} = nameof(T)
routine_name(::Type{<:Operation{P}}) where {P} = routine_name(P)
routine_name(::Type{<:AdjointOperation{P}}) where {P} = Symbol("adjoint_", routine_name(P))

# this is only a place holder
# we are not using struct because
# singleton types will get const prop
struct MeasureResult{T}
    result::T
end

@inline function Base.:(==)(lhs::MeasureResult, rhs)
    measure_cmp(lhs, rhs)
end

@inline function Base.:(==)(lhs, rhs::MeasureResult)
    measure_cmp(lhs, rhs)   
end

@inline function Base.:(==)(lhs::MeasureResult, rhs::MeasureResult)
    measure_cmp(lhs, rhs)
end

@noinline function measure_cmp(lhs, rhs)
    throw(IntrinsicError("cannot compare measurement result outside @device"))
end

struct Chain <: Routine
    args::Vector{Any}
    Chain(args...) = new(collect(Any, args))
end

# prop adjoint to leaves
Base.adjoint(c::Chain) = Chain(map(adjoint, c.args))

struct Typed
    obj
    type
end

struct Gate <: Routine
    operation # SSAValue/Routine
    locations # SSAValue/Locations
end

Base.adjoint(x::Gate) = Gate(adjoint(x.operation), x.locations)

struct Ctrl <: Routine
    gate::Gate
    ctrl # SSAValue/CtrlLocation
end

Base.adjoint(x::Ctrl) = Ctrl(adjoint(x.gate), x.ctrl)

struct BlockIR
    parent::IRCode
    nqubits::Int
    circuit::Chain
end

@as_record Chain
@as_record Gate
@as_record Ctrl
@as_record Typed
@as_record Operation
@as_record AdjointOperation

Base.length(c::Chain) = length(c.args)

function leaves(root::Chain)
    nodes = []
    sizehint!(nodes, length(root))
    for each in root.args
        if each isa Chain
            append!(nodes, leaves(each::Chain))
        else
            push!(nodes, each)
        end
    end
    return nodes
end

function Base.:(==)(lhs::Chain, rhs::Chain)
    mapreduce(==, &, lhs.args, rhs.args)
end

function Base.:(==)(lhs::Gate, rhs::Gate)
    lhs.operation == rhs.operation && lhs.locations == rhs.locations
end

function Base.:(==)(lhs::Ctrl, rhs::Ctrl)
    lhs.gate == rhs.gate && lhs.ctrl == rhs.ctrl
end
