#TODO: create relative references..
# - DONE given a batch find ref blob/value
#   - this way I do not need to store the full path to the batch
#   - syntax ideas: deref(bb, ref) or bb[ref]
# - avoid reloading frames...
#   - for this maybe we need a new object, ej: RefCacher
#   - syntax ideas: rc[ref]
#   - if the ref does not point to the cached batch it loads it...
#   - otherwise it reuse the cached one
#   - the cache size can be configured. 

# TODO:
# - DONE split this file
# - create blobyref(bb, ref) to produce a new ref but relative to bb
# - DONE finish relatives derefs

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Interface to implement
upref!(::BlobyRef, db) = error("Not implemented")
deref(::BlobyRef) = error("Not implemented")

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
import Base.getindex
Base.getindex(ref::BlobyRef{lT, rT}) where {lT, rT} = deref(ref)::rT

import Base.eltype
Base.eltype(::BlobyRef{lT, rT}) where {lT, rT} = rT

