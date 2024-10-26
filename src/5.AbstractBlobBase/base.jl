## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# getindex
import Base.getindex
Base.getindex(b::AbstractBlob, frame::AbstractString, key) = 
    getindex(getframe(b, frame), key) # custom frame
Base.getindex(b::AbstractBlob, T::Type, frame::AbstractString, key) = 
    getindex(getframe(b, frame), key)::T # custom frame
Base.getindex(b::AbstractBlob, key) = 
    getindex(getframe(b), key) # default frame
Base.getindex(b::AbstractBlob, T::Type, key) = 
    getindex(getframe(b), key)::T # default frame

Base.getindex(b::AbstractBlob) = getframe(b)
Base.getindex(b::AbstractBlob, key::Vector{String}) = 
    getframe(b, first(key))

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# TODO: Move to AbstractBlob
Base.setindex!(b::AbstractBlob, value, key) = 
    setindex!(b, value, BLOBBATCH_DEFAULT_FRAME_NAME, key)

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
Base.get(b::AbstractBlob, key, default) = Base.get(getframe(b), key, default)
Base.get(f::Function, b::AbstractBlob, key) = Base.get(f, getframe(b), key)
Base.get!(b::AbstractBlob, key, default) = Base.get!(getframe!(b), key, default)
Base.get!(f::Function, b::AbstractBlob, key) = Base.get!(f, getframe!(b), key)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.-
# TODO: Move to Absttract
# :set! :get! :dry 
# all in ram
function withblob!(f::Function, b::AbstractBlob, mode::Symbol, frame, key::String)
    if mode == :set!
        val = f()
        setindex!(b, val, frame, key)
        return blobyref(b, frame, key; rT = typeof(val))
    end
    # TODO: Think about it
    # What to do if 'frame, key' is missing
    # if mode == :get
    #     val = get(f, b, frame, key)
    #     return blobyref(b, frame, key; rT = typeof(val))
    # end
    if mode == :get!
        val = get!(f, b, frame, key)
        return blobyref(b, frame, key; rT = typeof(val))
    end
    if mode == :dry
        val = f()
        return blobyref(b, frame, key; rT = typeof(val))
    end
    error("Unknown mode, ", mode, ". see withblob! src")
end
withblob!(f::Function, b::AbstractBlob, mode::Symbol, key::String) = 
    withblob!(f, b, mode, BLOBBATCH_DEFAULT_FRAME_NAME, key)


## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# getframe
getframe!(b::AbstractBlob) = getframe!(b, BLOBBATCH_DEFAULT_FRAME_NAME)
getframe(b::AbstractBlob) = getframe(b, BLOBBATCH_DEFAULT_FRAME_NAME)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# blobyref
blobyref(b::AbstractBlob, key; rT = nothing) = 
    blobyref(b, BLOBBATCH_DEFAULT_FRAME_NAME, key; rT)


## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
import Base.haskey
Base.haskey(b::AbstractBlob, key) = haskey(b, BLOBBATCH_DEFAULT_FRAME_NAME, key)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
import Base.merge!
function Base.merge!(b::AbstractBlob, frame::AbstractString, vals)
    for (k, v) in vals
        setindex!(b, v, frame, k)
    end
end
Base.merge!(b::AbstractBlob, vals) = 
    merge!(b, BLOBBATCH_DEFAULT_FRAME_NAME, vals)