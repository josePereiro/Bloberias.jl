## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
blobbatch(B::Bloberia, group::AbstractString = BLOBERIA_DEFAULT_BATCH_GROUP) = BlobBatch(B, group)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# look for non full batch
function headbatch(B::Bloberia, group::AbstractString = BLOBERIA_DEFAULT_BATCH_GROUP)
    # no filesys, return new Batch
    isdir(B.root) || return BlobBatch(B, group)
    # find head
    # TODO: use walkdir (lazy iter)
    bb = nothing
    foreach_batch(B, group) do _bb
        _force_loadmeta!(_bb)
        count = get(_bb.meta, "blobs.count", 0)
        lim = get(_bb.meta, "blobs.lim", BLOBBATCHES_DEFAULT_SIZE_LIM)
        count < lim  || return :continue
        bb = _bb
        return :break
    end
    # If non found, return new
    return isnothing(bb) ? BlobBatch(B, group) : bb
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