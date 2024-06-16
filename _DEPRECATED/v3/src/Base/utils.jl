uuid_int() = uuid4().value
uuid_str() = repr(uuid4().value)

function _trydeserialize(path)
    isfile(path) || return nothing
    return deserialize(path)
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
