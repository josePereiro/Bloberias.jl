## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Constructor
Blob() = Blob(Ref(DEFAULT_BLOB_GROUP_NAME), OrderedDict())
# function Blob(lite, nonlite)
#     b = Blob()
#     _lite = _lite_dat!(b)
#     merge!(_lite, lite)
#     _nonlite = _nonlite_dat!(b)
#     merge!(_nonlite, nonlite)
#     return b
# end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# blobgroup

const DEFAULT_BLOB_GROUP_NAME = "0"

blobgroup(b::Blob) = isassigned(b.group) ? b.group[] : DEFAULT_BLOB_GROUP_NAME
blobgroup!(b::Blob, g::String) = (b.group[] = g)
blobgroup!(b::Blob) = blobgroup!(b, DEFAULT_BLOB_GROUP_NAME)

# TODO: withgroup do ... end interface. including a macro...

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
_lite_dat!(b::Blob) = get!(OrderedDict, b.dat, "lites")
_lite_group!(b::Blob, g::String) = get!(OrderedDict, _lite_dat!(b), g)
_lite_group!(b::Blob) = _lite_group!(b, blobgroup(b))

_nonlite_dat!(b::Blob) = get!(OrderedDict, b.dat, "non-lites")
_nonlite_group!(b::Blob, g::String) = get!(OrderedDict, _nonlite_dat!(b), g)
_nonlite_group!(b::Blob) = _nonlite_group!(b, blobgroup(b))

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# getindex
Base.getindex(b::Blob) = merge(_lite_group!(b), _nonlite_group!(b))

function Base.getindex(b::Blob, g::String, k::String)
    # lite
    _lite_group = _lite_group!(b, g)
    haskey(_lite_group, k) && return _lite_group[k]
    # non-lite
    _nonlite_group = _nonlite_group!(b, g)
    return _nonlite_group[k]
end
Base.getindex(b::Blob, g::String, k::Symbol) = getindex(b, g, string(k))
Base.getindex(b::Blob, k) = getindex(b, blobgroup(b), string(k))

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# setindex!
import Base.setindex!
function Base.setindex!(b::Blob, v, g::String, k::String) 
    _group = islite(v) ? _lite_group!(b, g) : _nonlite_group!(b, g)
    return setindex!(_group, v, k)
end
Base.setindex!(b::Blob, v, g::String, k::Symbol) = setindex!(b, v, g, string(k))
Base.setindex!(b::Blob, v, k::Symbol) = setindex!(b, v, blobgroup(b), k)


# merge!
function _merge!(b::Blob, ps::Pair...)
    for (k, v) in ps
        b[k] = v
    end
    return b
end

import Base.merge!
Base.merge!(b::Blob, p::Pair, ps::Pair...) = _merge!(b, p, ps...)
Base.merge!(b::Blob, d::Dict) = _merge!(b, d...)

# empty!
import Base.empty!
Base.empty!(b::Blob) = (empty!(b.dat); b)

# emptyblob!
emptyblob!(b::Blob) = (empty!(b); b)

# emptygroup!
function emptygroup!(b::Blob, g::String)
    empty!(_lite_group!(b, g))
    empty!(_nonlite_group!(b, g))
    return b
end
emptygroup!(b::Blob) = emptygroup!(b, blobgroup(b))