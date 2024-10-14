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
# :set! :get :get! :dry 
# all in ram
function withblob!(f::Function, rb::AbstractBlob, mode::Symbol, frame, key::String)
    if mode == :set!
        val = f()
        setindex!(rb, val, frame, key)
        return blobyref(rb, frame, key; rT = typeof(val))
    end
    if mode == :get
        val = get(f, rb, frame, key)
        return blobyref(rb, frame, key; rT = typeof(val))
    end
    if mode == :get!
        val = get!(f, rb, frame, key)
        return blobyref(rb, frame, key; rT = typeof(val))
    end
    if mode == :dry
        val = f()
        return blobyref(rb, frame, key; rT = typeof(val))
    end
    error("Unknown mode, ", mode, ". see withblob! src")
end
withblob!(f::Function, rb::AbstractBlob, mode::Symbol, key::String) = 
    withblob!(f, rb, mode, BLOBBATCH_DEFAULT_FRAME_NAME, key)


## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# getframe
getframe!(b::AbstractBlob) = getframe!(b, BLOBBATCH_DEFAULT_FRAME_NAME)
getframe(b::AbstractBlob) = getframe(b, BLOBBATCH_DEFAULT_FRAME_NAME)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# lock
import Base.lock
Base.lock(f::Function, rb::AbstractBlob; kwargs...) = _lock(f, rb; kwargs...)
Base.lock(rb::AbstractBlob; kwargs...) = _lock(rb; kwargs...) 

import Base.islocked
Base.islocked(rb::AbstractBlob) = _islocked(rb) 

import Base.unlock
Base.unlock(rb::AbstractBlob; force = false) = _unlock(rb; force) 

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# blobyref
blobyref(rb::AbstractBlob, key; rT = nothing) = 
    blobyref(rb, BLOBBATCH_DEFAULT_FRAME_NAME, key; rT)


    ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
Base.haskey(b::AbstractBlob, key) = haskey(b, BLOBBATCH_DEFAULT_FRAME_NAME, key)
