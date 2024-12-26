## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# BlobyObj interface

bloberia(b::Blob) = bloberia(b.bb)
blobbatch(b::Blob) = b.bb

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 

_hasblob(col::AbstractDict, id) =  haskey(col, id)
_hasblob(col, u) =  false

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
_show_bframes(io::IO, b::Blob) =
    _show_kT_frames(io, b, 
        b_uFRAME_FRAME_TYPE, 
        "Ram uframes"
    ) do kT_pairs, _u_frame
        for (key, val) in _u_frame
            push!(kT_pairs, string(key) => typeof(val))
        end
    end

import Base.show
function Base.show(io::IO, b::Blob)
    print(io, "Blob(")
    printstyled(io, repr(b.uuid); color = :blue)
    print(io, ")")

    _show_bframes(io, b) 
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# hashio!
hashio!(b::Blob, val, mode = :get!; 
    prefix = "cache", 
    hashfun = hash, 
    abs = true, 
    key = "val"
) = _hashio!(b, val, mode; prefix, hashfun, abs, key)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# lock interface
function _lock_obj_identity_hash(b::Blob, h0 = UInt64(0))::UInt64
    h = _lock_obj_identity_hash(b.bb, h0)
    h = hash(:Blob, h)
    h = hash(b.uuid, h)
    return h
end