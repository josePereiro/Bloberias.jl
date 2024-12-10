## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Constructor

BlobBatch(B::Bloberia, id) = BlobBatch(B, id,
    _batchpath(B.root, id),  # root
    FRAMES_DEPOT_TYPE(),
    TEMP_DEPOT_TYPE()
)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# shallow copy 
Base.copy(bb::BlobBatch) = BlobBatch(bb.B, bb.id)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# file sys

# build path
_batchpath(B_root::String, id::String) = joinpath(B_root, id)

_blobypath(bb::BlobBatch) = bb.root

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# BlobyObj interface

bloberia(bb::BlobBatch) = bb.B
blobbatch(bb::BlobBatch) = bb
batchpath(bb::BlobBatch) = bb.root
batchpath(bo::BlobyObj) = batchpath(blobbatch(bo))

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# getframe interface

frames_depot(bb::BlobBatch) = bb.frames

_dflt_frameid(::BlobBatch) = "bb0"
# The root to frames files
_frames_root(bb::BlobBatch) = bb.root

# frame validation
function _is_valid_access(::BlobBatch, fT) 
    fT == bUUIDS_FRAME_TYPE && return true
    fT == bb_bFRAME_FRAME_TYPE && return true
    fT == bb_bbFRAME_FRAME_TYPE && return true
    fT == META_FRAME_TYPE && return true
    return false
end


_getmeta(bb::BlobBatch) =
    _getframe!(bb, META_FRAMEID, META_FRAME_TYPE, META_DEPOT_TYPE)
getmeta(bb::BlobBatch) = _getmeta(bb::BlobBatch).dat

_getbuuids(bb::BlobBatch) =
    _getframe!(bb, bUUIDS_FRAMEID, bUUIDS_FRAME_TYPE, bUUIDS_DEPOT_TYPE)
getbuuids(bb::BlobBatch) = _getbuuids(bb).dat

_getbframe(bb::BlobBatch, id) = _getframe(bb, id)
getbframe(bb::BlobBatch, id)::VFRAME_DEPOT_TYPE = _getbframe(bb, id).dat

_getbframe!(bb::BlobBatch, id)=
    _getframe!(bb, id, bb_bFRAME_FRAME_TYPE, VFRAME_DEPOT_TYPE)
getbframe!(bb::BlobBatch, id)::VFRAME_DEPOT_TYPE = 
    _getbframe!(bb, id).dat

_getbbframe(bb::BlobBatch, id) = _getframe(bb, id)
getbbframe(bb::BlobBatch, id)::DFRAME_DEPOT_TYPE = _getbbframe(bb, id).dat

_getbbframe!(bb::BlobBatch, id) =
    _getframe!(bb, id, bb_bbFRAME_FRAME_TYPE, DFRAME_DEPOT_TYPE)
getbbframe!(bb::BlobBatch, id)::DFRAME_DEPOT_TYPE = 
    _getbbframe!(bb, id).dat

    
# Reimplementations

getframe(bb::BlobBatch, id) = _getframe(bb, id).dat

function getframe!(bb::BlobBatch, id, fT::Symbol)
    _check_access(bb, fT)
    fT == bb_bFRAME_FRAME_TYPE && return getbframe!(bb, id)
    fT == bUUIDS_FRAME_TYPE && return getbuuids(bb)
    fT == bb_bbFRAME_FRAME_TYPE && return getbbframe!(bb, id)
    return getmeta(bb)
end

# bbframes can only be created from bbs
function getframe!(bb::BlobBatch, id)
    id == META_FRAMEID && return getmeta(bb)
    id == bUUIDS_FRAMEID && return getbuuids(bb)
    return getbbframe!(bb, id)
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# An identity hash for the object
function _lock_obj_identity_hash(bb::BlobBatch, h0 = UInt64(0))::UInt64
    h = hash(h0)
    h = hash(:BlobBatch, h)
    h = hash(batchpath(bb), h)
    return h
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
import Base.rm
function Base.rm(bb::BlobBatch)
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

import Base.filesize
function Base.filesize(bb::BlobBatch)
    return _recursive_filesize(batchpath(bb))
end


## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# hashio!
hashio!(bb::BlobBatch, val, mode = :getser!; 
    prefix = "cache", 
    hashfun = hash, 
    abs = true, 
) = _hashio!(bb, val, mode; prefix, hashfun, abs)

# 
# ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# BlobBatch(B::Bloberia, id) = BlobBatch(B, id,
#     OrderedDict(), # meta
#     OrderedDict(), # bbframes
#     OrderedSet(),  # buuids
#     OrderedDict(), # bframes
#     OrderedDict()  # temp
# )

# ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# # shallow copy 
# Base.copy(bb::BlobBatch) = BlobBatch(bb.B, bb.id)

# ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# # obj struct interface
# bloberia(bb::BlobBatch) = bb.B
# blobbatch(bb::BlobBatch) = bb

# ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# # getindex

# import Base.getindex
# Base.getindex(bb::BlobBatch, ref::BlobyRef) = deref(bb, ref)

# Base.getindex(bb::BlobBatch, uuid::UInt128) = vblob(bb, uuid) 

# function _getvindex(bb::BlobBatch, i)
#     buuids = getbuuids(bb)
#     return Blob(bb, _getindex(buuids, i))
# end
# Base.getindex(bb::BlobBatch, i::Int) = _getvindex(bb, i)

# ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# # empty 

# empty_bbframes!(bb::BlobBatch) = empty!(bb.bbframes)
# empty_bbframe!(bb::BlobBatch, frame) =
#     haskey(bb.bbframes, frame) && empty!(bb.bbframes[frame])

# empty_bframes!(bb::BlobBatch) = empty!(bb.bframes)
# empty_bframe!(bb::BlobBatch, frame) =
#     haskey(bb.bframes, frame) && empty!(bb.bframes[frame])

# # isempty (ram only)
# function Base.isempty(bb::BlobBatch)
#     isempty(bb.buuids) || return false
#     isempty(bb.bbframes) || return false
#     isempty(bb.bframes) || return false
#     return true
# end

# ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# # Set the batch bframes limit
# function vbloblim(bb::BlobBatch)
#     bb_meta = getmeta(bb)
#     bb_lim = get(bb_meta, "config.blobs.lim", -1)::Int
#     bb_lim > 0 && return bb_lim
    
#     B_meta = getmeta(bb.B)
#     B_lim = get(B_meta, "config.batches.blobs.lim", typemax(Int))::Int
#     B_lim > 0 && return B_lim

#     return typemax(Int)
# end

# function vbloblim!(bb::BlobBatch, lim::Int)
#     bb_meta = getmeta(bb)
#     setindex!(bb_meta, lim, "config.blobs.lim")
# end

# function isfullbatch(bb::BlobBatch)
#     return blobcount(bb) >= vbloblim(bb)
# end

# function isoverflowed(bb::BlobBatch)
#     return blobcount(bb) > vbloblim(bb)
# end

# ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# # close/open interface
# # if it close it should be read only
# # serialization must fail
# # TODO: think per frame close (maybe a readonly flag)
# import Base.isopen
# function Base.isopen(bb::BlobBatch)
#     return get(getmeta(bb), "bb.isopen", true)::Bool
# end

# function open!(bb::BlobBatch)
#     setindex!(getmeta(bb), true, "bb.isopen")
# end

# function close!(bb::BlobBatch)
#     setindex!(getmeta(bb), false, "bb.isopen")
# end

# ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# # TODO: add tests
# import Base.delete!
# function Base.delete!(bb::BlobBatch)
#     rm(batchpath(bb); force = true, recursive = true)
# end

# function delete_bframe!(bb::BlobBatch, frame)
#     # ram
#     delete!(bb.bframes, frame)
#     # disk
#     _path = bframe_jlspath(bb, frame)
#     rm(_path; force = true, recursive = true)
#     return nothing
# end
