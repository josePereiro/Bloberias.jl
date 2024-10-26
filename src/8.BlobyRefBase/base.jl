## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Interface to implement
_merge_link!(::BlobyRef, rb) = error("Not implemented")
readref(::BlobyRef) = error("Not implemented")

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
import Base.getindex
Base.getindex(ref::BlobyRef{lT, rT}) where {lT, rT} = readref(ref)::rT

import Base.eltype
Base.eltype(::BlobyRef{lT, rT}) where {lT, rT} = rT

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Bloberia
function _merge_link!(ref::BlobyRef, B::Bloberia)
    ref.link["B.dir"] = bloberia_dir(B)
end

function blobyref(B::Bloberia)
    ref = BlobyRef(:Bloberia, Bloberia)
    _merge_link!(ref, B)
    return ref
end

_bloberia(ref::BlobyRef) = Bloberia(ref.link["B.dir"])
bloberia(ref::BlobyRef{:Bloberia, Bloberia}) = _bloberia(ref)
readref(ref::BlobyRef{:Bloberia, Bloberia}) = bloberia(ref)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# BlobBatch
function _merge_link!(ref::BlobyRef, bb::BlobBatch)
    ref.link["bb.group"] = bb.group
    ref.link["bb.uuid"] = bb.uuid
end

function blobyref(bb::BlobBatch)
    ref = BlobyRef(:BlobBatch, BlobBatch)
    _merge_link!(ref, bb.B)
    _merge_link!(ref, bb)
    return ref
end


_blobbatch(ref::BlobyRef) = blobbatch!(_bloberia(ref), ref.link["bb.group"], ref.link["bb.uuid"])
bloberia(ref::BlobyRef{:BlobBatch, BlobBatch}) = _bloberia(ref)
blobbatch(ref::BlobyRef{:BlobBatch, BlobBatch}) = _blobbatch(ref)
readref(ref::BlobyRef{:BlobBatch, BlobBatch}) = blobbatch(ref)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# btBlob
function _merge_link!(ref::BlobyRef, bt::btBlob, frame, key)
    ref.link["bt.uuid"] = bt.uuid
    ref.link["bt.frame"] = frame
    ref.link["bt.key"] = key
end

function blobyref(bt::btBlob)
    ref = BlobyRef(:btBlob, btBlob)
    _merge_link!(ref, bt.batch.B)
    _merge_link!(ref, bt.batch)
    _merge_link!(ref, bt, nothing, nothing)
    return ref
end

function blobyref(bt::btBlob, frame, key; rT = nothing)
    if isnothing(rT)
        val = getindex(bt, frame, key)
        rT = typeof(val)
    end
    ref = BlobyRef(:btBlobVal, rT)
    _merge_link!(ref, bt.batch.B)
    _merge_link!(ref, bt.batch)
    _merge_link!(ref, bt, frame, key)
    return ref
end

_bt_blob(ref::BlobyRef) = 
    blob!(_blobbatch(ref), ref.link["bt.uuid"])

bloberia(ref::BlobyRef{:btBlob, btBlob}) = _bloberia(ref)
bloberia(ref::BlobyRef{:btBlobVal, rT}) where rT = _bloberia(ref)
blobbatch(ref::BlobyRef{:btBlob, btBlob}) = _blobbatch(ref)
blobbatch(ref::BlobyRef{:btBlobVal, rT}) where rT = _blobbatch(ref)
blob(ref::BlobyRef{:btBlob, btBlob}) = _bt_blob(ref)
blob(ref::BlobyRef{:btBlobVal, rT}) where rT  = _bt_blob(ref)

readref(ref::BlobyRef{:btBlob, rT}) where rT = _bt_blob(ref)
readref(ref::BlobyRef{:btBlobVal, rT}) where rT = 
    getindex(_bt_blob(ref), ref.link["bt.frame"], ref.link["bt.key"])

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# raBlob
function _merge_link!(ref::BlobyRef, rb::raBlob, frame, key)
    ref.link["rb.id"] = rb.id
    ref.link["rb.frame"] = frame
    ref.link["rb.key"] = key
end

function blobyref(rb::raBlob)
    ref = BlobyRef(:raBlob, raBlob)
    _merge_link!(ref, rb.B)
    _merge_link!(ref, rb, nothing, nothing)
    return ref
end

function blobyref(rb::raBlob, frame, key; rT = nothing)
    if isnothing(rT)
        val = getindex(rb, frame, key)
        rT = typeof(val)
    end
    ref = BlobyRef(:raBlobVal, rT)
    _merge_link!(ref, rb.B)
    _merge_link!(ref, rb, frame, key)
    return ref
end

_ra_blob(ref::BlobyRef) = 
    blob!(_bloberia(ref), ref.link["rb.id"])

bloberia(ref::BlobyRef{:raBlob, raBlob}) = _bloberia(ref)
bloberia(ref::BlobyRef{:raBlobVal, rT}) where rT = _bloberia(ref)
blob(ref::BlobyRef{:raBlob, raBlob}) = _ra_blob(ref)
blob(ref::BlobyRef{:raBlobVal, rT}) where rT  = _ra_blob(ref)

readref(ref::BlobyRef{:raBlob, rT}) where rT = _ra_blob(ref)
readref(ref::BlobyRef{:raBlobVal, rT}) where rT = 
    getindex(_ra_blob(ref), ref.link["rb.frame"], ref.link["rb.key"])
    