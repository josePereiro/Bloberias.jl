## ------------------------------------------------------------------
_check_error(msg::String, v, allowed::Vector) = error(
    "Invalid ", msg, ".\n\t",
    "got      ", v, "::", typeof(v), "\n\t", 
    "expected Union{", join(allowed, ", "), "}",
)

## ------------------------------------------------------------------
function _check_unique_keys(vals)
    length(Set(_kv_key(val) for val in vals)) == length(vals) || error("Duplicated keys")
    return nothing
end

## ------------------------------------------------------------------
function _kv_print_val(io::IO, vals)
    print(io, "[")
    for p in vals
        k, val = _kv_key(p), _kv_val(p)
        if val === :__NOVAL; print(io, repr(k), ", ")
            else; print(io, repr(k), "=>", repr(val), ", ")
        end
    end
    print(io, "]")
end

function _kv_print_type(io::IO, vals)
    print(io, "[")
    for p in vals
        k, val = _kv_key(p), _kv_val(p)
        if val === :__NOVAL; print(io, repr(k), ", ")
            else; print(io, repr(k), "=>::", typeof(val), ", ")
        end
    end
    print(io, "]")
end

## ------------------------------------------------------------------
# function _kTDict(kT::DataType, d0::Dict)
#     _new = Dict{kT, valtype(d0)}()
#     for (k, v) in d0
#         _new[kT(k)] = v
#     end
#     return _new
# end

## ------------------------------------------------------------------
function _kv_type_vec(vals)
    ktvec = []
    for p in vals
        k, val = _kv_key(p), _kv_val(p)
        if val === :__NOVAL
            push!(ktvec, k)
        else
            push!(ktvec, k => typeof(val))
        end
    end
    return ktvec
end