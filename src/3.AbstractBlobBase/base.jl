## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# file sys

# The root to frames files
_frames_root(::AbstractBlob) = error("To implement")

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# getframe interface

hasframe_ram(ab::AbstractBlob, id::String) = haskey(frames_depot(ab), id)
hasframe_ram(ab::AbstractBlob) = hasframe_ram(ab, _dflt_frameid(ab))
hasframe_disk(ab::AbstractBlob, id::String) = isfile(_frame_path(_frames_root(ab), id))
hasframe_disk(ab::AbstractBlob) = hasframe_disk(ab, _dflt_frameid(ab))

# errorless
function _serialize_frame(path, frame::BlobyFrame)
    _mkpath(path)
    serialize(path, 
        (;
            dat = frame.dat, 
            path = frame.path, 
            id = frame.id, 
            fT = _frame_fT(frame), 
            dT = _frame_dT(frame), 
        )
    )
end

function _deserialize_frame(ab::AbstractBlob, fpath)
    ft = deserialize(fpath)
    # @assert ft.path == fpath
    return BlobyFrame{ft.fT, ft.dT}(ab, ft.id, ft.path, ft.dat)
end

function _try_loadframe!(ab::AbstractBlob, id)
    fpath = _frame_path(_frames_root(ab), id)
    isfile(fpath) || return nothing
    frame = _deserialize_frame(ab, fpath)
    setindex!(frames_depot(ab), frame, id)
    nothing
end

# errorless
function _onmiss_loadframe!(ab::AbstractBlob, id)
    hasframe_ram(ab, id) && return nothing
    _try_loadframe!(ab, id)
    return nothing
end

# baseline (To be reimplemented)
_is_valid_access(::AbstractBlob, fT) = false

# All access will be fisrt consider to be for loading, 
# later, implementations are responsables to validate writing
# If it is symmetric nothing needs to be done
_check_access(ab::AbstractBlob, fT::Symbol) = 
    _is_valid_access(ab, fT) || error(
        "Object (", typeof(ab), ") can not read this frame type, frame type: '", fT, "'"
    )
_check_access(ab::AbstractBlob, fr::BlobyFrame) = 
    _check_access(ab, _frame_fT(fr))

function _getframe(ab::AbstractBlob, id)
    _onmiss_loadframe!(ab::AbstractBlob, id)
    fr = get(frames_depot(ab), id) do
        error("Frame '", id, "' not found")
    end
    _check_access(ab, fr)
    return fr::BlobyFrame
end

function _getframe!(ab::AbstractBlob, id, fT, dT)
    _onmiss_loadframe!(ab::AbstractBlob, id)
    frame = get!(frames_depot(ab), id) do
        BlobyFrame{fT, dT}(ab, id, _frame_path(_frames_root(ab), id), dT())
    end
    fT1 = _frame_fT(frame)
    fT1 != fT && error("Frame do not have the expected type, type: ", repr(fT1), ", expected: ", repr(fT))
    _check_access(ab, fT)
    return frame::BlobyFrame{fT, dT}
end

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
    _serialize_frame(frame_path(ab, id), frames_depot(ab)[frame])

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Base dict interface

# To Implement
# getframe (Returns dictionary)
# getframe! (Returns dictionary)

# public interface returns fr.dat

getframe(ab::AbstractBlob) = getframe(ab, _dflt_frameid(ab))
getframe!(ab::AbstractBlob) = getframe!(ab, _dflt_frameid(ab))
    
import Base.getindex
function Base.getindex(ab::AbstractBlob, frameid, key)
    frame = getframe(ab, frameid)
    return Base.getindex(frame, key)
end
Base.getindex(ab::AbstractBlob, key) = 
    Base.getindex(ab, _dflt_frameid(ab), key)
Base.getindex(ab::AbstractBlob, frameid::Vector{String}) =
    getframe(ab, first(frameid))

Base.getindex(ab::AbstractBlob, ref::BlobyRef) = deref(ab, ref)

# index (order not controlled)
function Base.getindex(ab::AbstractBlob, i0::Int)
    for (i, el) in enumerate(ab)
        i0 == i && return el
    end
    error("Index our of bound!")
end


import Base.setindex!
function Base.setindex!(ab::AbstractBlob, val, frameid, key)
    frame = getframe!(ab, frameid)
    return Base.setindex!(frame, val, key)
end
Base.setindex!(ab::AbstractBlob, val, key) = 
    setindex!(ab, val, _dflt_frameid(ab), key)

Base.setindex!(ab::AbstractBlob, val, ref::BlobyRef) =
    setindex!(ab, val,
        ref.link["val.frame"]::String, 
        ref.link["val.key"]::String
    )

import Base.get
function Base.get(dflt::Function, ab::AbstractBlob, frameid, key)
    frame = getframe(ab, frameid)
    return get(dflt, frame, key)
end
Base.get(dflt::Function, ab::AbstractBlob, key) = 
    get(dflt, ab, _dflt_frameid(ab), key)
Base.get(ab::AbstractBlob, frameid, key, dflt) = get(() -> dflt, ab, frameid, key)
Base.get(ab::AbstractBlob, key, dflt) = get(() -> dflt, ab, _dflt_frameid(ab), key)

import Base.get!
function Base.get!(dflt::Function, ab::AbstractBlob, frameid, key)
    frame = getframe!(ab, frameid)
    return get!(dflt, frame, key)
end
Base.get!(dflt::Function, ab::AbstractBlob, key) = 
    get!(dflt, ab, _dflt_frameid(ab), key)
Base.get!(ab::AbstractBlob, key, frameid, dflt) = get!(() -> dflt, ab, frameid, key)
Base.get!(ab::AbstractBlob, key, dflt) = get!(() -> dflt, ab, _dflt_frameid(ab), key)


## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
function hasframe(ab::AbstractBlob, frameid) 
    hasframe_ram(ab, frameid) && return true
    hasframe_disk(ab, frameid) && return true
    return false
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Base
import Base.empty!
Base.empty!(ab::AbstractBlob) = empty!(frames_depot(ab))
Base.empty!(ab::AbstractBlob, id) = empty!(frames_depot(ab)[id])
import Base.isempty
Base.isempty(ab::AbstractBlob) = isempty(frames_depot(ab))

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# blobyref

blobyref(ab::AbstractBlob, key; rT = Any, abs = true) = 
    blobyref(ab, _dflt_frameid(ab), key; rT, abs)

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
    blobyio!(f, ab, _dflt_frameid(ab), key, mode)


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
    merge!(ab, _dflt_frameid(ab), vals; ow)

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