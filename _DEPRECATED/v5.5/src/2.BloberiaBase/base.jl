## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
const BLOBERIA_DEFAULT_RABLOB_ID = "0"
const BLOBERIA_DEFAULT_BBID = "0"
const BLOBERIA_DEFAULT_BBID_PREFIX = "0"
const BLOBERIA_DEFAULT_FRAME_NAME = "0"

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Constructor
Bloberia(root) = Bloberia(root, OrderedDict(), OrderedDict())

import Base.copy
Base.copy(B::Bloberia) = Bloberia(B.root) 

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# obj struct interface
bloberia(bo::Bloberia) = bo

# ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# # import Base.getindex
# # # uuid indexing

# # # TODO: think abount a batchs.jls for tracking existing batches
# # Base.getindex(B::Bloberia, uuid0::UInt128) = blobbatch(B, uuid0) # existing batch

# # # order indexing
# # # WARNING: order is not controlled
# # Base.getindex(B::Bloberia, idx::Integer) = blobbatch(B, idx) # existing batch
    
# # # collect fallback
# # function Base.getindex(B::Bloberia, idx)
# #     bbs = collect(eachbatch(B))
# #     return bbs[idx]
# # end

# # Base.getindex(B::Bloberia, key::String) = blob(B, key) # random access blob
# # Base.getindex(B::Bloberia) = blob!(B, BLOBERIA_DEFAULT_RABLOB_ID) # random access blob!


## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Use, uuids
# function _vblobcount_tout(B::Bloberia, bbid_prefix, tout)
#     count = 0
#     n_tasks = nthreads()
#     ch_size = 2 * n_tasks
#     bbs = eachbatch(B, bbid_prefix; n_tasks, ch_size)
#     t0 = time()
#     isout = false
#     # TODO: for doining faster I need a mem lasy foreach_batch
#     # - is the operation will be read only this is the fastest way
#     #   - lasy deserialized exist?
#     for bb in bbs
#         isout = tout > 0 && time() - t0 > tout
#         isout && break
#         count += vblobcount(bb)
#     end
#     return (isout, count)
# end

# 250000
function __vblobcount_tout_cb(_tot_count, _isout, tout)
    _lk = ReentrantLock()
    _tot_count[] = 0
    _t0 = time()
    _isout[] = false

    return (_bb) -> let
        _isout[] = tout > 0 && time() - _t0 > tout
        _isout[] && return :break
        _count = vblobcount(_bb)
        lock(_lk) do
            _tot_count[] += _count
        end
    end
end

function _vblobcount_tout(B::Bloberia, bbid_prefix, tout)
    lk = ReentrantLock()
    _tot_count = Ref(0)
    _t0 = time()
    _isout = Ref(false)

    ch_size = nthreads() * 10
    n_tasks = nthreads() * 10
    foreach_batch(
        __vblobcount_tout_cb(_tot_count, _isout, tout), 
        B, bbid_prefix; ch_size, n_tasks
    )
    return (_isout[], _tot_count[])
end

# TODO: cache on meta vblobcount aeach time you serialized! buuids
# have both cached_ and computed_
function vblobcount(B::Bloberia, bbid_prefix = nothing)
    _, count = _vblobcount_tout(B::Bloberia, bbid_prefix, Inf)
    return count
end

