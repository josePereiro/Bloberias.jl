## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
const BLOBBATCHES_DEFAULT_SIZE_LIM = 5000

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Constructor
const BLOBBATCH_DEFAULT_FRAME_NAME = "0"

BlobBatch(B::Bloberia, group::AbstractString, uuid) = BlobBatch(B, group, uuid,
    OrderedDict(), OrderedSet{Int128}(), OrderedDict(), 
    OrderedDict()
)
BlobBatch(B::Bloberia, group::AbstractString) = BlobBatch(B, group, uuid_int())
BlobBatch(B::Bloberia) = BlobBatch(B, BLOBBATCH_DEFAULT_FRAME_NAME, uuid_int())

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
function _bb_show_file_sortby(ph)
    name = basename(ph)
    name == "uuid.blobs.jls" && return "."
    name == "meta.jls" && return ".."
    return name
end

import Base.show
function Base.show(io::IO, bb::BlobBatch)
    _ondemand_loaduuids!(bb)
    print(io, "BlobBatch(", repr(bb.uuid), ") with ", length(bb.uuids), " blob(s)...")
    
    if !isempty(bb.frames)
        print(io, "\nRam frames: ")
        for (frame, _bb_frame) in bb.frames
            isempty(_bb_frame) && continue
            kT_pairs = Set()
            for (_, _b_frame) in _bb_frame
                for (key, val) in _b_frame
                    push!(kT_pairs, string(key) => typeof(val))
                end
            end
            print(io, "\n \"", frame, "\" ")
            _kv_print_type(io, kT_pairs; _typeof = identity)
        end
    end

    if isdir(bb)
        _bb_filesize = 0.0
        print(io, "\nDisk frames: ")
        b_files = readdir(batchpath(bb); join = true)
        sort!(b_files; by = _bb_show_file_sortby)
        for path in b_files
            endswith(path, ".frame.jls") || continue
            _filesize = filesize(path)
            val, unit = _canonical_bytes(_filesize)
            print(io, "\n  \"", basename(path), "\" ")
            print(io, "[")
            printstyled(io, string(round(val; digits = 3), " ", unit);
                color = :blue
            )
            print(io, "]")
            _bb_filesize += _filesize
        end
        val, unit = _canonical_bytes(_bb_filesize)
        print(io, "\ndisk usage: ")
        printstyled(io, string(round(val; digits = 3), " ", unit);
            color = :blue
        )
        
    end

end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# getindex
function getframe(bb::BlobBatch, frame::AbstractString)
    frame == "temp" && return bb.temp
    if frame == "meta" 
        _ondemand_loadmeta!(bb)
        return bb.meta
    end
    if frame == "uuids"
        _ondemand_loaduuids!(bb)
        return bb.uuids
    end
    _ondemand_loaddat!(bb, frame)
    return bb.frames[frame]
end
getframe(bb::BlobBatch) = getframe(bb, BLOBERIA_DEFAULT_FRAME_NAME)

import Base.getindex
Base.getindex(bb::BlobBatch, i::UInt128) = blob(bb, i)
function Base.getindex(bb::BlobBatch, i::Int)
    _ondemand_loaduuids!(bb)
    blob(bb, bb.uuids[i])
end
# TODO: think about it
function Base.getindex(bb::BlobBatch, framev::Vector) # get frame interface b[["bla"]]
    isempty(framev) && return getframe(bb)
    @assert length(framev) == 1
    return getframe(bb, first(framev))
end


# isempty
function Base.isempty(bb::BlobBatch)
    _ondemand_loaduuids!(bb)
    return isempty(bb.uuids)
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# hasframe
function hasframe_ram(bb::BlobBatch, frame)
    # check ram
    frame == "temp" && return true
    frame == "meta" && return true
    haskey(bb.frames, frame) && return true
    return false
end

function hasframe_disk(bb::BlobBatch, frame)
    frame == "temp" && return false
    if frame == "meta" 
        _file = meta_framepath(bb)
        return isfile(_file)
    end
    _file = dat_framepath(bb, frame)
    return isfile(_file)
end

# import Base.haskey
function hasframe(bb::BlobBatch, frame)
    hasframe_ram(bb, frame) && return true
    hasframe_disk(bb, frame) && return true
    return false
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Iterator
import Base.iterate
function Base.iterate(bb::BlobBatch)
    _ondemand_loaduuids!(bb)
    return iterate(bb.uuids)
end

Base.iterate(bb::BlobBatch, state) = iterate(bb.uuids, state)

import Base.length
Base.length(bb::BlobBatch) = blobcount(bb)

