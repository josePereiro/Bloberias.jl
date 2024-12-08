## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# BlobyObj interface

bloberia(b::Blob) = bloberia(b.bb)
blobbatch(b::Blob) = b.bb

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# getframe interface

_hasblob(col::AbstractDict, id) =  haskey(col, id)
_hasblob(col, u) =  false

function frames_depot(b::Blob) 
    b_depot = FRAMES_DEPOT_TYPE()
    _u = b.uuid
    for (id, fr) in frames_depot(b.bb)
        _frame_fT(fr) == bFRAME_FRAME_TYPE || continue
        haskey(fr.dat, _u) || continue
        b_depot[id] = frame
    end
    b_depot
end

# The root to frames files
_frames_root(b::Blob) = _frames_root(b.bb)
_default_id(::Blob) = "b0"

# frame validation
function _is_valid_access(::Blob, fT) 
    fT == bUUIDS_FRAME_TYPE && return true
    fT == bFRAME_FRAME_TYPE && return true
    return false
end

function getbframe(b::Blob, id)::BLOB_DEPOT_TYPE 
    _u = b.uuid
    _us = getbuuids(b.bb)
    _u ∈ _us || error("Blob not regitered!")
    _bfr = _getbframe(b.bb, id)
    return getindex(_bfr.dat, b.uuid)
end

function getbframe!(b::Blob, id)::BLOB_DEPOT_TYPE 
    _u = b.uuid
    _us = getbuuids(b.bb)
    push!(_us, _u)
    _bfr = _getbframe!(b.bb, id)
    _check_access(b, _bfr)
    return get!(BLOB_DEPOT_TYPE, _bfr.dat, _u)
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# bframes can only be created from bs
getframe(b::Blob, id) = getbframe(b, id)

getframe!(b::Blob, id) = getbframe!(b, id)

function foreach_bframe(f::Function, b::Blob, id0 = nothing)
    _u = b.uuid
    for (id, fr) in frames_depot(b.bb)
        _frame_fT(fr) == bFRAME_FRAME_TYPE || continue
        haskey(fr.dat, _u) || continue

        _do = isnothing(id0) 
        _do |= (id == id0)
        _do || return continue

        f(id, fr) === :break && break
    end
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
import Base.empty!
function Base.empty!(b::Blob, id = nothing)
    _u = b.uuid
    foreach_bframe(b, id) do _, fr
        empty!(fr.dat[_u])
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