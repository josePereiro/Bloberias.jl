## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Interface to implement
_merge_link!(::BlobyRef, db) = error("Not implemented")
readref(::BlobyRef) = error("Not implemented")

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
import Base.getindex
Base.getindex(ref::BlobyRef{lT, rT}) where {lT, rT} = readref(ref)::rT

import Base.eltype
Base.eltype(::BlobyRef{lT, rT}) where {lT, rT} = rT

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Bloberia
function _merge_link!(ref::BlobyRef, B::Bloberia)
    ref.link["B.root"] = bloberiapath(B)
end

function blobyref(B::Bloberia)
    ref = BlobyRef(:Bloberia, Bloberia)
    _merge_link!(ref, B)
    return ref
end

_bloberia(ref::BlobyRef) = Bloberia(ref.link["B.root"])
bloberia(ref::BlobyRef{:Bloberia, Bloberia}) = _bloberia(ref)
readref(ref::BlobyRef{:Bloberia, Bloberia}) = bloberia(ref)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# BlobBatch
function _merge_link!(ref::BlobyRef, bb::BlobBatch)
    ref.link["bb.id"] = bb.id
end

function blobyref(bb::BlobBatch)
    ref = BlobyRef(:BlobBatch, BlobBatch)
    _merge_link!(ref, bb.B)
    _merge_link!(ref, bb)
    return ref
end

_blobbatch(ref::BlobyRef) = blobbatch!(_bloberia(ref), ref.link["bb.id"])
bloberia(ref::BlobyRef{:BlobBatch, BlobBatch}) = _bloberia(ref)
blobbatch(ref::BlobyRef{:BlobBatch, BlobBatch}) = _blobbatch(ref)
readref(ref::BlobyRef{:BlobBatch, BlobBatch}) = blobbatch(ref)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# vBlob
function _merge_link!(ref::BlobyRef, vb::vBlob, frame, key)
    ref.link["vb.uuid"] = vb.uuid
    ref.link["vb.frame"] = frame
    ref.link["vb.key"] = key
end

function blobyref(vb::vBlob)
    ref = BlobyRef(:vBlob, vBlob)
    _merge_link!(ref, vb.batch.B)
    _merge_link!(ref, vb.batch)
    _merge_link!(ref, vb, nothing, nothing)
    return ref
end

function blobyref(vb::vBlob, frame, key; rT = nothing)
    if isnothing(rT)
        val = getindex(vb, frame, key)
        rT = typeof(val)
    end
    ref = BlobyRef(:vBlobVal, rT)
    _merge_link!(ref, vb.batch.B)
    _merge_link!(ref, vb.batch)
    _merge_link!(ref, vb, frame, key)
    return ref
end

_v_blob(ref::BlobyRef) = vblob!(_blobbatch(ref), ref.link["vb.uuid"])

bloberia(ref::BlobyRef{:vBlob, vBlob}) = _bloberia(ref)
bloberia(ref::BlobyRef{:vBlobVal, rT}) where rT = _bloberia(ref)
blobbatch(ref::BlobyRef{:vBlob, vBlob}) = _blobbatch(ref)
blobbatch(ref::BlobyRef{:vBlobVal, rT}) where rT = _blobbatch(ref)
blob(ref::BlobyRef{:vBlob, vBlob}) = _v_blob(ref)
blob(ref::BlobyRef{:vBlobVal, rT}) where rT  = _v_blob(ref)

readref(ref::BlobyRef{:vBlob, rT}) where rT = _v_blob(ref)
readref(ref::BlobyRef{:vBlobVal, rT}) where rT = 
    getindex(_v_blob(ref), ref.link["vb.frame"], ref.link["vb.key"])

# --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# dBlob
function _merge_link!(ref::BlobyRef, ::dBlob, frame, key)
    ref.link["db.frame"] = frame
    ref.link["db.key"] = key
end

function blobyref(db::dBlob)
    ref = BlobyRef(:dBlob, dBlob)
    _merge_link!(ref, db.batch.B)
    _merge_link!(ref, db.batch)
    _merge_link!(ref, db, nothing, nothing)
    return ref
end

function blobyref(db::dBlob, frame, key; rT = nothing)
    if isnothing(rT)
        val = getindex(db, frame, key)
        rT = typeof(val)
    end
    ref = BlobyRef(:dBlobVal, rT)
    _merge_link!(ref, db.batch.B)
    _merge_link!(ref, db.batch)
    _merge_link!(ref, db, frame, key)
    return ref
end

_ra_blob(ref::BlobyRef) = dblob(_blobbatch(ref))

bloberia(ref::BlobyRef{:dBlob, dBlob}) = _bloberia(ref)
bloberia(ref::BlobyRef{:dBlobVal, rT}) where rT = _bloberia(ref)
blob(ref::BlobyRef{:dBlob, dBlob}) = _ra_blob(ref)
blob(ref::BlobyRef{:dBlobVal, rT}) where rT  = _ra_blob(ref)

readref(ref::BlobyRef{:dBlob, rT}) where rT = _ra_blob(ref)
readref(ref::BlobyRef{:dBlobVal, rT}) where rT = 
    getindex(_ra_blob(ref), ref.link["db.frame"], ref.link["db.key"])
    