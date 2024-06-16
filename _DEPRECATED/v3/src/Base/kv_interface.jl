## ------------------------------------------------------------------
# Each data point must have an associated key [String].
# For a valueless pair we use an empty holder...

## ------------------------------------------------------------------
const _KV_NOVAL = :__NOVAL

## ------------------------------------------------------------------
# kw vec interface
_kv_key(obj::Pair) = string(first(obj))
_kv_key(obj::String) = obj
_kv_key(obj) = string(obj)

_kv_val(obj::Pair) = last(obj)
_kv_val(::String) = _KV_NOVAL
_kv_val(obj) = obj # for general objects

_kv_dict(vals::Vector) = Dict(_kv_key(v) => _kv_val(v) for v in vals)
# _kv_oddict(vals::Vector) = OrderedDict(_kv_key(v) => _kv_val(v) for v in vals)

function _kv_vec(vals...; kwargs...)
    vec = Any[]
    for val in vals
        push!(vec, val)
    end
    for val in kwargs
        push!(vec, _kv_key(val) => _kv_val(val))
    end
    return vec
end

_kv_vec(vals::AbstractDict) = Any[_kv_key(obj) => _kv_val(obj) for obj in vals]

function _kv_compact_vec!(kval::Vector)
    for (i, kv) in enumerate(kval)
        _kv_val(kv) == _KV_NOVAL || continue
        kval[i] = _kv_key(kv)
    end
    kval
end