## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# file sys

# The root to frames files
_frames_root(::AbstractBlob) = error("To implement")

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# getframe interface

hasframe_ram(ab::AbstractBlob, id::String) = haskey(frames_depot(ab), id)
hasframe_ram(ab::AbstractBlob) = hasframe_ram(ab, _default_id(ab))
hasframe_disk(ab::AbstractBlob, id::String) = isfile(_frame_path(_frames_root(ab), id))
hasframe_disk(ab::AbstractBlob) = hasframe_disk(ab, _default_id(ab))

# errorless
function _try_loadframe!(ab::AbstractBlob, id)
    fpath = _frame_path(_frames_root(ab), id)
    isfile(fpath) || return nothing
    frame = _deserialize(fpath)::BlobyFrame
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
        _serialize(frame_path(ab, id), frame)
    end
end
serialize_frame!(ab::AbstractBlob, id) = 
    _serialize_frames!(ab) do fr
        fr.id == id
    end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Base dict interface

# To Implement
# getframe (Returns dictionary)
# getframe! (Returns dictionary)

# public interface returns fr.dat

getframe(ab::AbstractBlob) = getframe(ab, _default_id(ab))
getframe!(ab::AbstractBlob) = getframe!(ab, _default_id(ab))
    
import Base.getindex
function Base.getindex(ab::AbstractBlob, frameid, key)
    frame = getframe(ab, frameid)
    return Base.getindex(frame, key)
end
Base.getindex(ab::AbstractBlob, key) = 
    Base.getindex(ab, _default_id(ab), key)
Base.getindex(ab::AbstractBlob, frameid::Vector{String}) =
    getframe(ab, first(frameid))

Base.getindex(ab::AbstractBlob, ref::BlobyRef) = deref(ab, ref)

import Base.setindex!
function Base.setindex!(ab::AbstractBlob, val, frameid, key)
    frame = getframe!(ab, frameid)
    return Base.setindex!(frame, val, key)
end
Base.setindex!(ab::AbstractBlob, val, key) = 
    setindex!(ab, val, _default_id(ab), key)

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
    get(dflt, ab, _default_id(ab), key)
Base.get(ab::AbstractBlob, key, frameid, dflt) = get(() -> dflt, ab, frameid, key)
Base.get(ab::AbstractBlob, key, dflt) = get(() -> dflt, ab, _default_id(ab), key)

import Base.get!
function Base.get!(dflt::Function, ab::AbstractBlob, frameid, key)
    frame = getframe!(ab, frameid)
    return get!(dflt, frame, key)
end
Base.get!(dflt::Function, ab::AbstractBlob, key) = 
    get!(dflt, ab, _default_id(ab), key)
Base.get!(ab::AbstractBlob, key, frameid, dflt) = get!(() -> dflt, ab, frameid, key)
Base.get!(ab::AbstractBlob, key, dflt) = get!(() -> dflt, ab, _default_id(ab), key)


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

blobyref(ab::AbstractBlob, key; rT = Int) = 
    blobyref(ab, _default_id(ab), key; rT)