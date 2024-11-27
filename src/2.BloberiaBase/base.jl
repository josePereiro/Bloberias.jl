## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
const BLOBERIA_DEFAULT_RABLOB_ID = "0"
const BLOBERIA_DEFAULT_BATCH_GROUP = "0"
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
function vblobcount(B::Bloberia, bbid_pt = nothing)
    count = 0
    bbs = eachbatch(B, bbid_pt)
    for bb in bbs
        count += vblobcount(bb)
    end
    return count
end

