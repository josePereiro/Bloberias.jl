## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Create an blobbatch

function blobbatch(B::Bloberia, bbid0) # existing batch
    bb = BlobBatch(B, bbid0)
    isdir(bb) && error("Batch not found, bbid0: ", repr(bbid0))
    return bb
end

function blobbatch!(B::Bloberia, bbid0) # potentially new
    return BlobBatch(B, bbid0)
end
blobbatch!(B::Bloberia) = blobbatch!(B, BLOBERIA_DEFAULT_BBID)

# ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# # WARNING: Order is not warranted
# function blobbatch(B::Bloberia, idx::Integer) # existing batch
#     idx < 1 && error("idx < 0, idx: ", idx)
#     batchcount = 0
#     for (i, bb) in enumerate(B)
#         i == idx && return bb
#         batchcount += 1
#     end
#     idx > batchcount && error("idx > batchcount, idx: ", idx, ", batchcount: ", batchcount)
# end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# random ids
const BLOBERIA_DEFAULT_BBID_PREFIX = "0"

function rbbid(prefix::String) 
    prefix = isempty(prefix) ? BLOBERIA_DEFAULT_BBID_PREFIX : prefix
    string(prefix, ".", uuid_str())
end
rbbid() = rbbid(BLOBERIA_DEFAULT_BBID_PREFIX)

rbid() = uuid_int()

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
function getbatch!(filter::Function, B::Bloberia, prefix, missid)
    # find head
    for bb in eachbatch(B, prefix)
        filter(bb) === true || continue
        return bb
    end
    # or new
    return blobbatch!(B, missid)
end

getbatch!(B::Bloberia, prefix, missid) = 
    getbatch!(_constant(true), B, prefix, missid)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# look for non full batchs
function headbatch(B::Bloberia, prefix = "")::BlobBatch 
    # find head
    for bb in eachbatch(B, prefix)
        isfullbatch(bb) && continue
        return bb
    end
    # or error
    error("No empty batch found, prefix ", repr(prefix))
end

# TODO: TAI: change for a getbatch!(filter::Function, B, prefix, missid)
function headbatch!(missid::Function, B::Bloberia, prefix = nothing)::BlobBatch
    # find head
    for bb in eachbatch(B, prefix)
        isfullbatch(bb) && continue
        return bb
    end
    # or new
    return blobbatch!(B, missid())
end
headbatch!(B::Bloberia, prefix = "", missid = rbbid(prefix)) = 
    headbatch!(() -> missid, B, prefix)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 

function batchcount(B::Bloberia)
    count = 0
    _foreach_batch_chless(B) do dir
        count += 1
    end
    return count
end