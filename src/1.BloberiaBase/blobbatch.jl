## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Create an empty blobbatch
blobbatch!(B::Bloberia, group::AbstractString, uuid::UInt128) = 
    BlobBatch(B, group, uuid)
blobbatch!(B::Bloberia, group::AbstractString) = BlobBatch(B, group)
blobbatch!(B::Bloberia) = BlobBatch(B, BLOBERIA_DEFAULT_BATCH_GROUP)

function blobbatch(B::Bloberia, uuid0::UInt128) # existing batch
    for bb in B
        bb.uuid == uuid0 && return bb
    end
    error("Batch not found, uuid: ", repr(uuid0))
end

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
# look for non full batch
# or give a new one
function headbatch!(B::Bloberia, group::AbstractString)::BlobBatch
    # find head
    for bb in eachbatch(B, group)
        isfullbatch(_bb) && continue
        return bb
    end
    return blobbatch!(B, group)
end
headbatch!(B::Bloberia) = headbatch!(B, BLOBERIA_DEFAULT_BATCH_GROUP)


## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
function batchcount(B::Bloberia)
    count = 0
    bb_root = blobbatches_dir(B)
    isdir(bb_root) || return count
    for path in readdir(bb_root; join = true)
        _isbatchdir(path) || continue
        count += 1
    end
    return count
end