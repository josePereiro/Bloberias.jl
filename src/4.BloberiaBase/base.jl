## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Constructor
Bloberia(root) = Bloberia(root, FRAMES_DEPOT_TYPE(), TEMP_DEPOT_TYPE())

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# shallow copy 
import Base.copy
Base.copy(B::Bloberia) = Bloberia(B.root) 

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# file sys

_blobypath(B::Bloberia) = B.root

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# BlobyObj interface

bloberia(B::Bloberia) = B
bloberiapath(B::Bloberia) = B.root
bloberiapath(bo::BlobyObj) = bloberiapath(bloberia(bo))

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# getframe interface

_dflt_frameid(::Bloberia) = "meta"
# The root to frames files (frame interface)
_frames_root(B::Bloberia) = B.root

# frame validation
function _is_valid_access(::Bloberia, fT) 
    fT == META_FRAME_TYPE && return true
    return false
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# getframe interface

frames_depot(B::Bloberia) = B.frames

_getmeta(B::Bloberia) =
     _getframe!(B, META_FRAMEID, META_FRAME_TYPE, META_DEPOT_TYPE)
getmeta(B::Bloberia) = _getmeta(B).dat
    
# Reimplementations
function getframe(B::Bloberia, id)
    # TAI, add 
    id == META_FRAMEID || error("Bloberia only have a 'meta' frame")
    getmeta(B)
end
getframe(B::Bloberia) = getmeta(B)

getframe!(B::Bloberia, id) = getframe(B, id)
getframe!(B::Bloberia) = getframe(B)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# lock interface
function _lock_obj_identity_hash(B::Bloberia, h0 = UInt64(0))::UInt64
    h = hash(h0)
    h = hash(:Bloberia, h)
    h = hash(bloberiapath(B), h)
    return h
end

function unlock_batches(B::Bloberia; force = true)
    for bb in B
        unlock(bb; force)
    end
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Set the batch bframes limit
function bloblim(bb::BlobBatch)
    bb_meta = getmeta(bb)
    bb_lim = get(bb_meta, "config.blobs.lim", -1)::Int
    bb_lim > 0 && return bb_lim
    
    B_meta = getmeta(bb.B)
    B_lim = get(B_meta, "config.batches.blobs.lim", typemax(Int))::Int
    B_lim > 0 && return B_lim

    return typemax(Int)
end

function bloblim!(bb::BlobBatch, lim::Int)
    bb_meta = getmeta(bb)
    setindex!(bb_meta, lim, "config.blobs.lim")
end

function isfullbatch(bb::BlobBatch)
    return blobcount(bb) >= bloblim(bb)
end

function isoverflowed(bb::BlobBatch)
    return blobcount(bb) > bloblim(bb)
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
function _blobcount_tout(B::Bloberia, bbid_prefix, tout; 
        blobcountfun = _blobcount_cached
    )
    _lk = ReentrantLock()
    _tot_count = 0
    _t0 = time()
    _isout = false

    ch_size = nthreads() * 2
    n_tasks = nthreads()
    foreach_batch(
        B, bbid_prefix; ch_size, n_tasks
    ) do _bb
        _isout = tout > 0 && time() - _t0 > tout
        _isout && return :break
        _count = blobcountfun(_bb)
        lock(_lk) do
            _tot_count += _count
        end
    end
    return (_isout, _tot_count)
end

function blobcount(B::Bloberia, bbid_prefix = nothing)
    _, count = _blobcount_tout(B::Bloberia, bbid_prefix, Inf)
    return count
end

import Base.filesize
function Base.filesize(B::Bloberia)
    return _recursive_filesize(bloberiapath(B))
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
import Base.mkpath
Base.mkpath(B) = mkpath(bloberiapath(B))


# const BLOBERIA_DEFAULT_RABLOB_ID = "0"
# const BLOBERIA_DEFAULT_BBID = "0"
# const BLOBERIA_DEFAULT_BBID_PREFIX = "0"
# const BLOBERIA_DEFAULT_FRAME_NAME = "0"

# ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# # Constructor
# Bloberia(root) = Bloberia(root, OrderedDict(), OrderedDict())

# import Base.copy
# Base.copy(B::Bloberia) = Bloberia(B.root) 

# ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# # obj struct interface
# bloberia(bo::Bloberia) = bo

# # ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# # # import Base.getindex
# # # # uuid indexing

# # # # TODO: think abount a batchs.jls for tracking existing batches
# # # Base.getindex(B::Bloberia, uuid0::UInt128) = blobbatch(B, uuid0) # existing batch

# # # # order indexing
# # # # WARNING: order is not controlled
# # # Base.getindex(B::Bloberia, idx::Integer) = blobbatch(B, idx) # existing batch
    
# # # # collect fallback
# # # function Base.getindex(B::Bloberia, idx)
# # #     bbs = collect(eachbatch(B))
# # #     return bbs[idx]
# # # end

# # # Base.getindex(B::Bloberia, key::String) = blob(B, key) # random access blob
# # # Base.getindex(B::Bloberia) = blob!(B, BLOBERIA_DEFAULT_RABLOB_ID) # random access blob!


# ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# # Use, uuids
# # function _blobcount_tout(B::Bloberia, bbid_prefix, tout)
# #     count = 0
# #     n_tasks = nthreads()
# #     ch_size = 2 * n_tasks
# #     bbs = eachbatch(B, bbid_prefix; n_tasks, ch_size)
# #     t0 = time()
# #     isout = false
# #     # TODO: for doining faster I need a mem lasy foreach_batch
# #     # - is the operation will be read only this is the fastest way
# #     #   - lasy deserialized exist?
# #     for bb in bbs
# #         isout = tout > 0 && time() - t0 > tout
# #         isout && break
# #         count += blobcount(bb)
# #     end
# #     return (isout, count)
# # end

# # 250000
# function __blobcount_tout_cb(_tot_count, _isout, tout)
#     _lk = ReentrantLock()
#     _tot_count[] = 0
#     _t0 = time()
#     _isout[] = false

#     return (_bb) -> let
#         _isout[] = tout > 0 && time() - _t0 > tout
#         _isout[] && return :break
#         _count = blobcount(_bb)
#         lock(_lk) do
#             _tot_count[] += _count
#         end
#     end
# end

# # TODO: cache on meta blobcount aeach time you serialized! buuids
# # have both cached_ and computed_
# function blobcount(B::Bloberia, bbid_prefix = nothing)
#     _, count = _blobcount_tout(B::Bloberia, bbid_prefix, Inf)
#     return count
# end

