## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Constructor
Blob(bb::BlobBatch, uuid) = Blob(bb, uuid, OrderedDict(), OrderedDict(), OrderedDict())
Blob(bb::BlobBatch) = Blob(bb, uuid_int())


## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# getframe
function _get_level1(b::Blob, k::String)
    k == "temp" && return b.temp
    if k == "lite"
        _ondemand_loadlite!(b.batch)
        return k.lite
    end
    return nothing
end

function getframe(b::Blob, k::String)
    ret = _get_level1(b, k)
    isnothing(ret) || return ret
    _ondemand_loadnonlite!(b.batch, k)
    return b.nonlite[k]
end

function getframe(f::Function, b::Blob, k::String)
    ret = _get_level1(b, k)
    isnothing(ret) || return ret
    _ondemand_loadnonlite!(b.batch, k)
    return get(f, b.nonlite, k)
end

function getframe(b::Blob, k::String, dflt)
    ret = _get_level1(b, k)
    isnothing(ret) || return ret
    _ondemand_loadnonlite!(b.batch, k)
    return get(b.nonlite, k, dflt)
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# setindex
function Base.setindex!(b::Blob, value, group::AbstractString, key::AbstractString)
    group == "temp" && return setindex!(b.temp, value, key)
    if islite(value)
        _ondemand_loadlite!(b.batch)
        _group_dat = get!(OrderedDict, b.lite, group)
        return setindex!(_group_dat, value, key)
    else
        _ondemand_loadnonlite!(b.batch, group)
        _group_dat = get!(OrderedDict, b.nonlite, group)
        return setindex!(_group_dat, value, key)
    end
end
Base.setindex!(b::Blob, value, key) = 
    setindex!(b, value, BLOBBATCH_DEFAULT_GROUP, key)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# getindex
# load on demand each frame
# lite first, non-lite later
import Base.getindex
function Base.getindex(b::Blob, group::AbstractString, key)
    group == "temp" && return getindex(b.temp, key)
    
    _dict = nothing
    _ondemand_loadlite!(b.batch)
    if haskey(b.lite, group)
        _dict = b.lite[group]
        haskey(_dict, key) && return _dict[key]
    end
    _ondemand_loadnonlite!(b.batch, group)
    if haskey(b.nonlite, group)
        _dict = b.nonlite[group]
        haskey(_dict, key) && return _dict[key]
    end
    isnothing(_dict) && b.lite[group] # for pretty error
    return _dict[key] # for pretty error
end
# Base.getindex(b::Blob, key) = getindex(b, BLOBBATCH_DEFAULT_GROUP, key)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
commmit(b::Blob) = _commmit!(b.batch, b)
