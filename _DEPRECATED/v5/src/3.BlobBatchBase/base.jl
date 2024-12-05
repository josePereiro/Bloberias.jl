## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Constructor
BlobBatch(B::Bloberia, id) = BlobBatch(B, id,
    OrderedDict(), # meta
    OrderedDict(), # dframes
    OrderedSet(),  # vuuids
    OrderedDict(), # vframes
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
    vuuids = getvuuids(bb)
    return vBlob(bb, _getindex(vuuids, i))
end
Base.getindex(bb::BlobBatch, i::Int) = _getvindex(bb, i)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# empty 

empty_bframes!(bb::BlobBatch) = empty!(bb.dframes)
empty_bframe!(bb::BlobBatch, frame) =
    haskey(bb.dframes, frame) && empty!(bb.dframes[frame])

empty_vframes!(bb::BlobBatch) = empty!(bb.vframes)
empty_vframe!(bb::BlobBatch, frame) =
    haskey(bb.vframes, frame) && empty!(bb.vframes[frame])

# isempty (ram only)
function Base.isempty(bb::BlobBatch)
    isempty(bb.vuuids) || return false
    isempty(bb.dframes) || return false
    isempty(bb.vframes) || return false
    return true
end

# isempty (ram only)
import Base.empty!
function Base.empty!(bb::BlobBatch)
    empty!(bb.meta)
    empty!(bb.vuuids)
    empty!(bb.temp)
    empty!(bb.dframes)
    empty!(bb.vframes)
    return nothing
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Set the batch vframes limit
function vbloblim(bb::BlobBatch)
    bb_meta = getmeta(bb)
    bb_lim = get(bb_meta, "config.vblobs.lim", -1)::Int
    bb_lim > 0 && return bb_lim
    
    B_meta = getmeta(bb.B)
    B_lim = get(B_meta, "config.batches.vblobs.lim", typemax(Int))::Int
    B_lim > 0 && return B_lim

    return typemax(Int)
end

function vbloblim!(bb::BlobBatch, lim::Int)
    bb_meta = getmeta(bb)
    setindex!(bb_meta, lim, "config.vblobs.lim")
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

function delete_vframe!(bb::BlobBatch, frame)
    # ram
    delete!(bb.vframes, frame)
    # disk
    _path = vframe_jlspath(bb, frame)
    rm(_path; force = true, recursive = true)
    return nothing
end
