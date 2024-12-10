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

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
_repr(s::String) = s
_repr(o) = repr(o)

function Base.show(io::IO, ref::BlobyRef)
    i = 0
    for (pel, color) in [
            ("B.root", :light_green), 
            ("bb.id", :green), 
            ("b.uuid", :cyan), 
            ("val.frame", :blue), 
            ("val.key", :blue)
        ]
        haskey(ref.link, pel) || continue
        i != 0 && printstyled(io, "//"; color = :normal)
        printstyled(io, _repr(ref.link[pel]); color)
        i += 1
    end
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# This one returns the blob
# - the ref is an input
function blobyio!(f::Function, 
        ref::BlobyRef, 
        mode::Symbol;
        ab = deref_srcblob(ref)
    )
    frame = ref.link["val.frame"]::String
    key = ref.link["val.key"]::String
    blobyio!(f, ab, mode, frame, key)
    return ab
end
