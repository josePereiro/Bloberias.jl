## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Constructor
Bloberia(root) = Bloberia(root, OrderedDict(), OrderedDict())
Bloberia() = Bloberia("")

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# filesys
function _hasfilesys(B::Bloberia)
    isempty(B.root) && return false
    return true
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
function foreach_batch(f::Function, B::Bloberia, group_pt = nothing; sortfun = identity)
    ret = nothing
    paths = sortfun(readdir(B.root; join = true))
    for path in paths
        _isbatchdir(path) || continue
        group, uuid = _split_batchname(path)

        # filter
        _ismatch(group_pt, group) || continue

        # function
        # TODO: LOCK IO (?)
        bb = BlobBatch(B, group, uuid)
        ret = f(bb)
        ret === :break && break
    end
    return ret
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
function headbatch(B::Bloberia, group::AbstractString = BLOBBATCH_DEFAULT_GROUP)
    # no filesys, return new Batch
    isdir(B.root) || return BlobBatch(B, group)
    # find head
    # TODO: use walkdir (lazy iter)
    bb = nothing
    foreach_batch(B, group) do _bb
        _force_loadmeta!(_bb)
        count = get(_bb.meta, "blobs.count", 0)
        lim = get(_bb.meta, "blobs.lim", 1000)
        count < lim  || return :continue
        bb = _bb
        return :break
    end
    # If non found, return new
    return isnothing(bb) ? BlobBatch(B, group) : bb
end