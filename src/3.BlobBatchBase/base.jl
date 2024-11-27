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
# close/open interface
# if it close it should be read only
# serialization must fail
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

# ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# # getindex

# import Base.getindex
# Base.getindex(bb::BlobBatch, uuid::UInt128) = blob(bb, uuid) 
# Base.getindex(bb::BlobBatch, i::Int) = blob(bb, i)

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
function isfullbatch(bb::BlobBatch)
    B_meta = getmeta(bb.B)
    B_lim = get(B_meta, "config.batches.vblobs.lim", typemax(Int))::Int
    bb_meta = getmeta(bb)
    bb_lim = get(bb_meta, "config.vblobs.lim", typemax(Int))::Int
    lim = min(B_lim, bb_lim)
    return vblobcount(bb) >= lim
end
