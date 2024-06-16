uuid_int() = uuid4().value
uuid_str() = repr(uuid4().value)

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