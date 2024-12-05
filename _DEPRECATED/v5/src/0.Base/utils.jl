uuid_one() = UInt128(1)
# uuid_int() = uuid4().value
function uuid_int()
    _1 = uuid_one()
    while true
        _u = uuid4().value
        _u != _1 && return _u
    end
end
uuid_str() = repr(uuid_int())

_noop(x...) = nothing

function _trydeserialize(path; onerr = _noop)
    isfile(path) || return nothing
    return _deserialize(path; onerr)
end

# _ismatch(pt, str)
_ismatch(pt::Function, y) = pt(y) === true
_ismatch(pt::AbstractChar, y::AbstractString) = isequal(string(pt), y)
_ismatch(pt::AbstractString, y::AbstractString) = startswith(y, pt)
_ismatch(pt::Regex, y::String) = !isnothing(match(pt, string(y)))
_ismatch(pt) = Base.Fix1(_ismatch, pt)
_ismatch(::Nothing, y) = true  # pass
_ismatch(pt, y) = isequal(pt, y)

function _mkpath(path)
    dir = dirname(path)
    isdir(dir) || mkpath(dir)
end

function _serialize(path::AbstractString, value; onerr = rethrow)
    try; serialize(path, value)
    catch e
        @info("WRITE ERROR: '", path, "'")
        return onerr(e)
    end
end

function _deserialize(path::AbstractString; onerr = rethrow)
    try; deserialize(path)
    catch e
        @info("READ ERROR: '", path, "'")
        return onerr(e)
    end
end

function _quoted_join(col, sep)
    strs = String[]
    for el in col
        push!(strs, string("\"", el, "\""))
    end
    return join(strs, sep)
end


function _canonical_bytes(bytes)
    bytes < 1024 && return (bytes, "bytes")
    bytes /= 1024
    bytes < 1024 && return (bytes, "kilobytes")
    bytes /= 1024
    bytes < 1024 && return (bytes, "Megabytes")
    bytes /= 1024
    bytes < 1024 && return (bytes, "Gigabytes")
    bytes /= 1024
    return (bytes, "Tb")
end

function _pretty_print_pairs(io::IO, k, v)
    print(io, string(k), ": ")
    printstyled(io, string(v); color = :blue)
end

function _hashed_id(s::AbstractString, args...)
    h0 = hash(0)
    for a in args
        h0 = hash(a, h0)
    end
    return string(s, repr(h0))
end

# function _field_hash(obj, h = 0)
#     h = hash(h)
#     for f in fieldnames(typeof(obj))
#         v = getfield(obj, f)
#         _valid_type = false
#         _valid_type |= isa(v, String)
#         _valid_type |= isa(v, Symbol)
#         _valid_type |= isa(v, Integer)
#         _valid_type || continue
#         h = hash(v, h)
#     end
#     return h
# end


function _recursive_filesize(root0)
    fsize = 0.0;
    for (root, _, files) in walkdir(root0)
        for file in files
            fsize += filesize(joinpath(root, file)) # path to files
        end
    end
    return fsize
end

function _getindex(os::OrderedSet, i0)
    for (i, v) in enumerate(os)
        i == i0 && return v
    end
    throw(BoundsError(os, i0))
end