const BLOBBATCH_DEFAULT_FRAME_NAME = "0"

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# getframe
_deftframe(b::AbstractBlob) = getframe(b, BLOBBATCH_DEFAULT_FRAME_NAME)
_deftframe!(b::AbstractBlob) = getframe!(b, BLOBBATCH_DEFAULT_FRAME_NAME)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# setindex
function Base.setindex!(b::AbstractBlob, value, frame::AbstractString, key)
    _b_frame = getframe!(b, frame) # add frame if required
    return setindex!(_b_frame, value, key)
end
Base.setindex!(b::AbstractBlob, value, key) = 
    setindex!(b, value, BLOBBATCH_DEFAULT_FRAME_NAME, key)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# getindex
import Base.getindex
Base.getindex(b::AbstractBlob, frame::AbstractString, key) = 
    getindex(getframe(b, frame), key) # custom frame
Base.getindex(b::AbstractBlob, T::Type, frame::AbstractString, key) = 
    getindex(getframe(b, frame), key)::T # custom frame
Base.getindex(b::AbstractBlob, key) = 
    getindex(_deftframe(b), key) # default frame
Base.getindex(b::AbstractBlob, T::Type, key) = 
    getindex(_deftframe(b), key)::T # default frame

Base.getindex(b::AbstractBlob) = getframes(b)
Base.getindex(b::AbstractBlob, frame::Vector{String}) = 
    getframe(b, first(frame))
Base.getindex(b::AbstractBlob, ref::BlobyRef) = deref(b, ref)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# import Base.get
Base.get(b::AbstractBlob, frame::AbstractString, key, default) = 
    Base.get(getframe(b, frame), key, default)
Base.get(f::Function, b::AbstractBlob, frame::AbstractString, key) = 
    Base.get(f, getframe(b, frame), key)
Base.get!(b::AbstractBlob, frame::AbstractString, key, default) = 
    Base.get!(getframe!(b, frame), key, default)
Base.get!(f::Function, b::AbstractBlob, frame::AbstractString, key) = 
    Base.get!(f, getframe!(b, frame), key)

# default
Base.get(b::AbstractBlob, key, default) = Base.get(_deftframe(b), key, default)
Base.get(f::Function, b::AbstractBlob, key) = Base.get(f, _deftframe(b), key)
Base.get!(b::AbstractBlob, key, default) = Base.get!(_deftframe!(b), key, default)
Base.get!(f::Function, b::AbstractBlob, key) = Base.get!(f, _deftframe!(b), key)

# ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# DOING:
# Add:
# :set! = setindex! f() to ram
# :setser! = set! and then serialize!
# :get! = get! f() from ram/disk
# ::getser! = get! and then, if  issing, serialize!
# :dry = run f() return empty ref
function blobyio!(f::Function, b::AbstractBlob, mode::Symbol, frame, key::String)
    if mode == :set!
        val = f()
        setindex!(b, val, frame, key)
        return blobyref(b, frame, key, typeof(val))
    end
    if mode == :setser!
        val = f()
        setindex!(b, val, frame, key)
        serialize!(b)
        return blobyref(b, frame, key, typeof(val))
    end
    # TODO: Think about it
    # What to do if 'frame, key' is missing
    # if mode == :get
    #     val = get(f, b, frame, key)
    #     return blobyref(b, frame, key, typeof(val))
    # end
    if mode == :get!
        val = get!(b, frame, key)
        return blobyref(b, frame, key, typeof(val))
    end
    if mode == :getser!
        _ser_flag = false
        val = get!(b, frame, key) do
            _ser_flag = true
            return f()
        end
        _ser_flag && serialize!(b)
        return blobyref(b, frame, key, typeof(val))
    end
    if mode == :dry
        val = f()
        return blobyref(b, frame, key, typeof(val))
    end
    error("Unknown mode, ", mode, ". see blobyio! src")
end
blobyio!(f::Function, b::AbstractBlob, mode::Symbol, key::String) = 
    blobyio!(f, b, mode, BLOBBATCH_DEFAULT_FRAME_NAME, key)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# blobyref
blobyref(b::AbstractBlob, key, rT = Any) = 
    blobyref(b, BLOBBATCH_DEFAULT_FRAME_NAME, key, rT)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
function hashio!(b::AbstractBlob, val; 
        prefix = "cache", 
        hashfun = hash, 
        mode = :getser!
    )
    frame = string(prefix, ".", repr(hashfun(val)))
    ref = blobyref(b, frame, "val", typeof(val))
    blobyio!(() -> val, ref, mode)
    return ref
end

# ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# import Base.haskey
# Base.haskey(b::AbstractBlob, key) = haskey(b, BLOBBATCH_DEFAULT_FRAME_NAME, key)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
import Base.merge!
function Base.merge!(b::AbstractBlob, frame::AbstractString, vals)
    for (k, v) in vals
        setindex!(b, v, frame, k)
    end
end
Base.merge!(b::AbstractBlob, vals) = 
    merge!(b, BLOBBATCH_DEFAULT_FRAME_NAME, vals)