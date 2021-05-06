macro intrinsic(ex)
    esc(intrinsic_m(ex))
end

macro intrinsic(n::Int, ex)
    esc(intrinsic_m(ex, n))
end

function intrinsic_m(ex, n::Int=1)
    if ex isa Symbol
        def = JLStruct(;name=Symbol(ex, :Gate), supertype=IntrinsicRoutine)
        binding_name = ex
        binding = :(Core.@__doc__ const $ex = $(def.name)())
    else
        name, args, kw, whereparams, rettype = split_function_head(ex)
        kw === nothing || error("cannot have kwargs in intrinsic operation")
        rettype === nothing || error("cannot have rettype in intrinsic operation")

        typevars=whereparams
        fields = JLField[]
        for each in args
            field = @match each begin
                :($fname::$type) => JLField(;name=fname, type)
                ::Symbol => JLField(;name=each)
                _ => error("cannot handle $each")
            end
            push!(fields, field)
        end
        def = JLStruct(;name, fields, supertype=IntrinsicRoutine, typevars)
        binding_name = name
        binding = nothing
    end

    quote
        Core.@__doc__ $(codegen_ast(def))
        $(codegen_helpers(def, n, binding_name))
        $binding
    end
end

nqubits(::Type{T}) where {T <: Routine} = error("YaoHIR.nqubits is not defined for $T")
isintrinsic(::Type{T}) where T = false

function codegen_helpers(def::JLStruct, n::Int, name::Symbol)
    quote
        $YaoHIR.nqubits(::Type{<:$(def.name)}) = $n
        $YaoHIR.isintrinsic(::Type{<:$(def.name)}) = true
        $YaoHIR.routine_name(::Type{<:$(def.name)}) = $(QuoteNode(name))
        $MLStyle.@as_record $(def.name)
    end
end

@intrinsic X
@intrinsic Y
@intrinsic Z
@intrinsic H
@intrinsic S
@intrinsic T
@intrinsic shift(θ::T) where {T}
@intrinsic Rx(θ::T) where {T}
@intrinsic Ry(θ::T) where {T}
@intrinsic Rz(θ::T) where {T}
@intrinsic UGate(α::T, β::T, γ::T) where {T}
