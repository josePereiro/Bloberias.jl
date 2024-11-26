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

_ismatch(f::Function, y) = f(y) === true
_ismatch(y, f::Function) = _ismatch(f, y)
_ismatch(x::AbstractChar, y::AbstractString) = isequal(string(x), y)
_ismatch(x::AbstractString, y::AbstractChar) = _ismatch(y, x)
_ismatch(r::Regex, y::String) = !isnothing(match(r, y))
_ismatch(r::Regex, y) = _ismatch(r, string(y))
_ismatch(y, r::Regex) = _ismatch(r, y)
_ismatch(x, y) = isequal(x, y)
_ismatch(x) = Base.Fix1(_ismatch, x)
_ismatch(::Nothing, y) = true  # pass

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