## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Create an empty blobbatch
blobbatch!(B::Bloberia, group::AbstractString ) = BlobBatch(B, group)
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
function headbatch!(B::Bloberia, group::AbstractString = BLOBERIA_DEFAULT_BATCH_GROUP)::BlobBatch
    # no filesys, return new Batch
    isdir(B.root) || return BlobBatch(B, group)
    # find head
    bb = BlobBatch(B, group) 
    foreach_batch(B, group) do _bb
        _force_loadmeta!(_bb)
        count = blobcount(_bb)
        lim = get(_bb.meta, "blobs.lim", BLOBBATCHES_DEFAULT_SIZE_LIM)
        count < lim  || return :continue
        bb = _bb
        return :break
    end
    return bb
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
function batchcount(B::Bloberia)
    count = 0
    isdir(B.root) || return count
    for path in readdir(B.root; join = true)
        _isbatchdir(path) || continue
        count += 1
    end
    return count
end