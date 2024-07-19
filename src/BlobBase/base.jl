## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Constructor
Blob(bb::BlobBatch, uuid) = Blob(bb, uuid, OrderedDict())
Blob(bb::BlobBatch) = Blob(bb, uuid_int())

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
import Base.show
function Base.show(io::IO, b::Blob)
    print(io, "Blob(", repr(b.uuid), ")")
    for (frame, _bb_frame) in b.batch.frames
        haskey(_bb_frame, b.uuid) || continue
        _b_frame = _bb_frame[b.uuid]
        isempty(_b_frame) && continue
        println(io)
        print(io, " \"", frame, "\" ")
        _kv_print_type(io, _b_frame; _typeof = typeof)
    end
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# getframe
# load on demand each frame
function getframe(b::Blob, frame::AbstractString)
    frame == "temp" && return b.temp
    _ondemand_loaddat!(b.batch, frame) # loaded on batch
    return b.batch.frames[frame][b.uuid]
end
getframe(b::Blob) = getframe(b, BLOBBATCH_DEFAULT_FRAME_NAME)

function getframe!(b::Blob, frame::AbstractString)
    frame == "temp" && return b.temp
    _ondemand_loaddat!(b.batch, frame) # loaded on batch
    _bb_frame = get!(OrderedDict, b.batch.frames, frame)
    _b_frame = get!(OrderedDict, _bb_frame, b.uuid)
    return _b_frame
end
getframe!(b::Blob) = getframe!(b, BLOBBATCH_DEFAULT_FRAME_NAME)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
hasframe(b::Blob, frame::String) = hasframe(b.batch, frame)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# getindex
import Base.getindex
Base.getindex(b::Blob, frame::AbstractString, key) = getindex(getframe(b, frame), key)
Base.getindex(b::Blob, key) = getindex(getframe(b), key)

# TODO: think about it
function Base.getindex(b::Blob, framev::Vector) # get frame interface b[["bla"]]
    isempty(framev) && return getframe(b)
    @assert length(framev) == 1
    return getframe(b, first(framev))
end

# setindex
function Base.setindex!(b::Blob, value, frame::AbstractString, key)
    frame == :temp && return setindex!(b.temp, value, key)
    # add frame if required
    _b_frame = getframe!(b, frame)
    return setindex!(_b_frame, value, key)
end
Base.setindex!(b::Blob, value, key) = 
    setindex!(b, value, BLOBBATCH_DEFAULT_FRAME_NAME, key)

import Base.get
function Base.get(dflt::Function, b::Blob, frame::AbstractString, key)
    frame == "temp" && return get(dflt, b.temp, key)
    _ondemand_loaddat!(b.batch, frame) # loaded on batch
    haskey(b.batch.frames, frame) || return dflt()
    _bb_frame = b.batch.frames[frame]
    haskey(_bb_frame, b.uuid) || return dflt()
    _b_frame = _bb_frame[b.uuid]
    return get(dflt, _b_frame, key)
end
Base.get(dflt::Function, b::Blob, key) = get(dflt, b, BLOBBATCH_DEFAULT_FRAME_NAME, key)
Base.get(b::Blob, key, frame::AbstractString, dflt) = get(()-> dflt, b, frame, key)
Base.get(b::Blob, key, dflt) = get(b, BLOBBATCH_DEFAULT_FRAME_NAME, key, dflt)

import Base.get!
function Base.get!(dflt::Function, b::Blob, frame::AbstractString, key)
    frame == "temp" && return get!(dflt, b.temp, key)
    _ondemand_loaddat!(b.batch, frame) # loaded on batch
    _bb_frame = get!(OrderedDict, b.batch.frames, frame)
    _b_frame = get!(OrderedDict, _bb_frame, b.uuid)
    return get!(dflt, _b_frame, key)
end
Base.get!(dflt::Function, b::Blob, key) = get!(dflt, b, BLOBBATCH_DEFAULT_FRAME_NAME, key)
Base.get!(b::Blob, frame::AbstractString, key, dflt) = get!(()-> dflt, b, frame, key)
Base.get!(b::Blob, key, dflt) = get!(b, BLOBBATCH_DEFAULT_FRAME_NAME, key, dflt)

import Base.haskey
function Base.haskey(b::Blob, frame::AbstractString, key)
    frame == "temp" && return haskey(b.temp, key)
    _ondemand_loaddat!(b.batch, frame) # loaded on batch
    haskey(b.batch.frames, frame) || return false
    _bb_frame = b.batch.frames[frame]
    haskey(_bb_frame, b.uuid) || return false
    _b_frame = _bb_frame[b.uuid]
    return haskey(_b_frame, key)
end
Base.haskey(b::Blob, key) = haskey(b, BLOBBATCH_DEFAULT_FRAME_NAME, key)



## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# merge!
import Base.merge!
function Base.merge!(b::Blob, frame::String, dat; force = true, prefix = "")
    _b_frame = getframe!(b, frame)
    for (k, v) in dat
        k = string(prefix, k)
        # check overwrite
        !force && haskey(_b_frame, k) && error("Overwrite is not allowed, use `force=true`")
        _b_frame[k] = v
    end
    return b
end
Base.merge!(b::Blob, dat; force = true, prefix = "") = 
    merge!(b, BLOBBATCH_DEFAULT_FRAME_NAME, dat; force, prefix)