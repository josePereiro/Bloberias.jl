
## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# frame data interface

# getframe!(bb..) can only creates frames from 
# which setindex! can act...
function getframe!(b::Blob, id::String)
    _bfr = _getbframe!(b.bb, id)
    return get!(_bfr.dat, b.uuid) do
        # register new uuid
        push!(getbuuids!(b.bb), b.uuid)
        return DICT_DEPOT_TYPE()
    end
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
import Base.setindex!
function Base.setindex!(b::Blob, val, frameid::String, key::String) 
    _bfr = getframe!(b, frameid)
    setindex!(_bfr, val, key)
end

import Base.get
function Base.get(dflt::Function, b::Blob, frameid::String, key::String)
    hasframe(b, frameid) || return dflt()
    bb_fr = getframe(b.bb, frameid)
    haskey(bb_fr, b.uuid) || return dflt()
    return get(dflt, bb_fr[b.uuid], key)
end

import Base.get!
function Base.get!(dflt::Function, b::Blob, frameid::String, key::String)
    b_fr = getframe!(b, frameid)
    return get!(dflt, b_fr, key)
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 

function foreach_bframe(f::Function, b::Blob, id0 = nothing)
    _u = b.uuid
    for (id, fr) in frames_depot(b.bb)
        _frame_fT(fr) == bb_bFRAME_FRAME_TYPE || continue
        haskey(fr.dat, _u) || continue

        _do = isnothing(id0) 
        _do |= (id == id0)
        _do || return continue

        f(id, fr) === :break && break
    end
end

# TODO: This have an ill interaction with onmiss loading.
# - onmiss means that theframe is empty, and a blob only empty! a fraction of the frame
# - it is a problem? maybe not
import Base.empty!
function Base.empty!(b::Blob, id = nothing)
    _u = b.uuid
    foreach_bframe(b, id) do _, fr
        _datu = fr.dat[_u]
        empty!(_datu)
    end
end
import Base.isempty
function Base.isempty(b::Blob, id = nothing)
    _hassome = false
    _u = b.uuid
    foreach_bframe(b, id) do _id, fr
        _datu = fr.dat[_u]
        _hassome |= !isempty(_datu)
        _hassome || return :break
    end
    return !_hassome
end

# import Base.empty!
# Base.empty!(b::Blob) = empty!(b.bb.frames)
# Base.empty!(b::Blob, id::String) = empty!(b.bb.frames[id])
# import Base.isempty
# Base.isempty(b::Blob) = isempty(b.bb.frames)
