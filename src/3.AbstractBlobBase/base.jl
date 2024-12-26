## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# blobyref

blobyref(ab::AbstractBlob, key; rT = Any, abs = true) = 
    blobyref(ab, dflt_frameid(ab), key; rT, abs)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# :set! = setindex! f() to ram
# :setser! = set! and then serialize!
# :get! = get! f() from ram/disk
# ::getser! = get! and then, if  issing, serialize!
# :dry = run f() return empty ref
function blobyio!(f::Function, ab::AbstractBlob, frame, key::String, mode::Symbol = :get!)
    if mode == :set!
        val = f()
        setindex!(ab, val, frame, key)
        return blobyref(ab, frame, key; rT = typeof(val))
    end
    if mode == :setser!
        val = f()
        setindex!(ab, val, frame, key)
        serialize!(ab)
        return blobyref(ab, frame, key, rT = typeof(val))
    end
    # TODO: Think about it
    # What to do if 'frame, key' is missing
    # if mode == :get
    #     val = get(f, ab, frame, key)
    #     return blobyref(ab, frame, key, typeof(val))
    # end
    if mode == :get!
        val = get!(f, ab, frame, key)
        return blobyref(ab, frame, key, rT = typeof(val))
    end
    if mode == :getser!
        _ser_flag = false
        val = get!(ab, frame, key) do
            _ser_flag = true
            return f()
        end
        _ser_flag && serialize!(ab)
        return blobyref(ab, frame, key; rT = typeof(val))
    end
    if mode == :dry
        val = f()
        return blobyref(ab, frame, key; rT = typeof(val))
    end
    error("Unknown mode, ", mode, ". see blobyio! src")
end
blobyio!(f::Function, ab::AbstractBlob, key::String, mode::Symbol = :get!) = 
    blobyio!(f, ab, dflt_frameid(ab), key, mode)


## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
function _hashio!(ab::AbstractBlob, val, mode = :getser!; 
        prefix = "cache", 
        hashfun = hash, 
        abs = true, 
        key = "val"
    )
    frame = string(prefix, ".", repr(hashfun(val)))
    ref = blobyref(ab, frame, key; rT = typeof(val), abs)
    blobyio!(() -> val, ref, mode; ab)
    return ref
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
import Base.merge!
function Base.merge!(ab::AbstractBlob, frameid::AbstractString, vals)
    for (k, v) in vals
        setindex!(ab, v, frameid, k)
    end
end
Base.merge!(ab::AbstractBlob, vals; ow = true) = 
    merge!(ab, dflt_frameid(ab), vals; ow)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
import Base.hash
function Base.hash(ab::AbstractBlob, h::UInt)
    T = typeof(ab)
    h = hash(T, h)
    for sym in fieldnames(T)
        v = getfield(ab, sym)
        _valid = v isa AbstractString
        _valid |= v isa Number
        _valid || continue
        h = hash(v, h)
    end
    return h
end

import Base.rm
Base.rm(ab::AbstractBlob, id::String; force = true) =
    rm(frame_path(ab, id); force, recursive = true)
    
## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# serialization
function serialize_frames!(f::Function, ab::AbstractBlob)
    for (id, frame) in frames_depot(ab)
        f(frame) || continue
        isempty(frame) && continue
        _serialize_frame(frame_path(ab, id), frame)
    end
end
serialize_frame!(ab::AbstractBlob, id) = 
    _serialize_frame(frame_path(ab, id), _depot_frame(ab, id))
