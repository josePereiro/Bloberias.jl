## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
function deref!(rc::RefCacher, ref::BlobyRef)
    # load from cache
    bb_path = _deref_batchpath(ref)
    if haskey(rc.bb_cache, bb_path)
        bb = rc.bb_cache[bb_path]
        return deref(bb, ref)
    end
    # up cache
    # TODO implement variable size cache
    bb = blobbatch(ref)
    isnothing(bb) && return deref(ref)
    empty!(rc.bb_cache)
    setindex!(rc.bb_cache, bb, bb_path)
    return deref(bb, ref)
end