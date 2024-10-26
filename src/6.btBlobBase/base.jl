## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Constructor
btBlob(bb::BlobBatch) = btBlob(bb, uuid_int())

# shallow copy 
btBlob(bt::btBlob) = btBlob(b.batch, bt.uuid)

import Base.copy
Base.copy(bt::btBlob) = btBlob(bt)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
blobbatch(b::btBlob) = b.batch
bloberia(b::btBlob) = bloberia(blobbatch(b))

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
import Base.show
function Base.show(io::IO, b::btBlob)
    print(io, "btBlob(", repr(b.uuid), ")")
    for (frame, _bb_frame) in b.batch.frames
        haskey(_bb_frame, b.uuid) || continue
        _b_frame = _bb_frame[b.uuid]
        isempty(_b_frame) && continue
        println(io)
        print(io, " \"", frame, "\" ")
        _kv_print_type(io, _b_frame; _typeof = typeof)
    end
end

# setindex
function Base.setindex!(b::btBlob, value, frame::AbstractString, key)
    _b_frame = getframe!(b, frame) # add frame if required
    return setindex!(_b_frame, value, key)
end
Base.setindex!(b::btBlob, value, key) = 
    setindex!(b, value, BLOBBATCH_DEFAULT_FRAME_NAME, key)

import Base.get
function Base.get(dflt::Function, b::btBlob, frame::AbstractString, key)
    _ondemand_loaddat!(b.batch, frame) # loaded on batch
    haskey(b.batch.frames, frame) || return dflt()
    _bb_frame = b.batch.frames[frame]
    haskey(_bb_frame, b.uuid) || return dflt()
    _b_frame = _bb_frame[b.uuid]
    return get(dflt, _b_frame, key)
end
# Base.get(dflt::Function, b::btBlob, key) = get(dflt, b, BLOBBATCH_DEFAULT_FRAME_NAME, key)
# Base.get(b::btBlob, key, frame::AbstractString, dflt) = get(()-> dflt, b, frame, key)
# Base.get(b::btBlob, key, dflt) = get(b, BLOBBATCH_DEFAULT_FRAME_NAME, key, dflt)

import Base.get!
function Base.get!(dflt::Function, b::btBlob, frame::AbstractString, key)
    # frame == "temp" && return get!(dflt, b.temp, key)
    _ondemand_loaddat!(b.batch, frame) # loaded on batch
    _bb_frame = get!(OrderedDict, b.batch.frames, frame)
    _b_frame = get!(OrderedDict, _bb_frame, b.uuid)
    return get!(dflt, _b_frame, key)
end
Base.get!(dflt::Function, b::btBlob, key) = get!(dflt, b, BLOBBATCH_DEFAULT_FRAME_NAME, key)
Base.get!(b::btBlob, frame::AbstractString, key, dflt) = get!(()-> dflt, b, frame, key)
Base.get!(b::btBlob, key, dflt) = get!(b, BLOBBATCH_DEFAULT_FRAME_NAME, key, dflt)

import Base.haskey
function Base.haskey(b::btBlob, frame::AbstractString, key)
    # frame == "temp" && return haskey(b.temp, key)
    _ondemand_loaddat!(b.batch, frame) # loaded on batch
    haskey(b.batch.frames, frame) || return false
    _bb_frame = b.batch.frames[frame]
    haskey(_bb_frame, b.uuid) || return false
    _b_frame = _bb_frame[b.uuid]
    return haskey(_b_frame, key)
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# merge!
import Base.merge!
function Base.merge!(b::btBlob, frame::String, dat; force = true, prefix = "")
    _b_frame = getframe!(b, frame)
    for (k, v) in dat
        k = string(prefix, k)
        # check overwrite
        !force && haskey(_b_frame, k) && error("Overwrite is not allowed, use `force=true`")
        _b_frame[k] = v
    end
    return b
end
Base.merge!(b::btBlob, dat; force = true, prefix = "") = 
    merge!(b, BLOBBATCH_DEFAULT_FRAME_NAME, dat; force, prefix)

