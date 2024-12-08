## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
function deref!(rc::RefCacher, ref::BlobyRef)
    # load from cache
    roothash = deref_roothash(ref)
    if haskey(rc.ab_cache, roothash)
        ab = rc.ab_cache[roothash]
        return getindex(ab, ref)
    end
    # up cache
    ab = deref_rootblob!(ref)
    # TODO implement variable size cache
    empty!(rc.ab_cache) # TODO implement variable size cache
    setindex!(rc.ab_cache, ab, roothash)
    return getindex(ab, ref)
end