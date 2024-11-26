## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Create an empty blobbatch
function blobbatch(B::Bloberia, bbid0) # existing batch
    path = _batchpath(bloberiapath(B), bbid0)
    bb = _bb_from_path(B, path, nothing, [])
    isnothing(bb) && error("Batch not found, bbid0: ", repr(bbid0))
    return bb
end

function blobbatch!(B::Bloberia, bbid0) # potentially new
    return BlobBatch(B, bbid0)
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# WARNING: Order is not warranted
function blobbatch(B::Bloberia, idx::Integer) # existing batch
    idx < 1 && error("idx < 0, idx: ", idx)
    batchcount = 0
    for (i, bb) in enumerate(B)
        i == idx && return bb
        batchcount += 1
    end
    idx > batchcount && error("idx > batchcount, idx: ", idx, ", batchcount: ", batchcount)
end


## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# TODO: Use a close/open or readonly interface better... Thin about it...
# # look for non full batch
# # or give a new one
# function headbatch!(B::Bloberia, group::AbstractString)::BlobBatch
#     # find head
#     for bb in eachbatch(B, group)
#         isfullbatch(bb) && continue
#         return bb
#     end
#     return blobbatch!(B, group)
# end
# headbatch!(B::Bloberia) = headbatch!(B, BLOBERIA_DEFAULT_BATCH_GROUP)


## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
function batchcount(B::Bloberia)
    count = 0
    _foreach_batch_chless(B) do _
        count += 1
    end
    return count
end