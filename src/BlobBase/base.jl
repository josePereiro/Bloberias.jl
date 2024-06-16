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
# work on RAM, see commit to sync with batch
function Base.setindex!(b::Blob, value, frame::AbstractString, key)
    frame == :temp && return setindex!(b.temp, value, key)
    # add frame if required
    _b_frame = getframe!(b, frame)
    return setindex!(_b_frame, value, key)
end
Base.setindex!(b::Blob, value, key) = 
    setindex!(b, value, BLOBBATCH_DEFAULT_FRAME_NAME, key)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# merge!
import Base.merge!
function Base.merge!(b::Blob, frame::String, dat)
    _b_frame = getframe!(b, frame)
    merge!(_b_frame, dat)
    return b
end
Base.merge!(b::Blob, dat) = merge!(b, BLOBBATCH_DEFAULT_FRAME_NAME, dat)