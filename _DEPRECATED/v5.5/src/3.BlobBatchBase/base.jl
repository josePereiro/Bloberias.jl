## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Constructor
BlobBatch(B::Bloberia, id) = BlobBatch(B, id,
    OrderedDict(), # meta
    OrderedDict(), # bbframes
    OrderedSet(),  # buuids
    OrderedDict(), # bframes
    OrderedDict()  # temp
)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# shallow copy 
Base.copy(bb::BlobBatch) = BlobBatch(bb.B, bb.id)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# obj struct interface
bloberia(bb::BlobBatch) = bb.B
blobbatch(bb::BlobBatch) = bb

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# getindex

import Base.getindex
Base.getindex(bb::BlobBatch, ref::BlobyRef) = deref(bb, ref)

Base.getindex(bb::BlobBatch, uuid::UInt128) = vblob(bb, uuid) 

function _getvindex(bb::BlobBatch, i)
    buuids = getbuuids(bb)
    return Blob(bb, _getindex(buuids, i))
end
Base.getindex(bb::BlobBatch, i::Int) = _getvindex(bb, i)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# empty 

empty_bbframes!(bb::BlobBatch) = empty!(bb.bbframes)
empty_bbframe!(bb::BlobBatch, frame) =
    haskey(bb.bbframes, frame) && empty!(bb.bbframes[frame])

empty_bframes!(bb::BlobBatch) = empty!(bb.bframes)
empty_bframe!(bb::BlobBatch, frame) =
    haskey(bb.bframes, frame) && empty!(bb.bframes[frame])

# isempty (ram only)
function Base.isempty(bb::BlobBatch)
    isempty(bb.buuids) || return false
    isempty(bb.bbframes) || return false
    isempty(bb.bframes) || return false
    return true
end

# isempty (ram only)
import Base.empty!
function Base.empty!(bb::BlobBatch)
    empty!(bb.meta)
    empty!(bb.buuids)
    empty!(bb.temp)
    empty!(bb.bbframes)
    empty!(bb.bframes)
    return nothing
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Set the batch bframes limit
function vbloblim(bb::BlobBatch)
    bb_meta = getmeta(bb)
    bb_lim = get(bb_meta, "config.blobs.lim", -1)::Int
    bb_lim > 0 && return bb_lim
    
    B_meta = getmeta(bb.B)
    B_lim = get(B_meta, "config.batches.blobs.lim", typemax(Int))::Int
    B_lim > 0 && return B_lim

    return typemax(Int)
end

function vbloblim!(bb::BlobBatch, lim::Int)
    bb_meta = getmeta(bb)
    setindex!(bb_meta, lim, "config.blobs.lim")
end

function isfullbatch(bb::BlobBatch)
    return vblobcount(bb) >= vbloblim(bb)
end

function isoverflowed(bb::BlobBatch)
    return vblobcount(bb) > vbloblim(bb)
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# close/open interface
# if it close it should be read only
# serialization must fail
# TODO: think per frame close (maybe a readonly flag)
import Base.isopen
function Base.isopen(bb::BlobBatch)
    return get(getmeta(bb), "bb.isopen", true)::Bool
end

function open!(bb::BlobBatch)
    setindex!(getmeta(bb), true, "bb.isopen")
end

function close!(bb::BlobBatch)
    setindex!(getmeta(bb), false, "bb.isopen")
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# TODO: add tests
import Base.delete!
function Base.delete!(bb::BlobBatch)
    rm(batchpath(bb); force = true, recursive = true)
end

function delete_bframe!(bb::BlobBatch, frame)
    # ram
    delete!(bb.bframes, frame)
    # disk
    _path = bframe_jlspath(bb, frame)
    rm(_path; force = true, recursive = true)
    return nothing
end
