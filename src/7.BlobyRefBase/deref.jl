## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# - non bang methods should fail if object are missing
#   - that is, it will try to find them in ram aor disk

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Bloberia

# unsafe
_deref_bloberiapath(ref::BlobyRef) = ref.link["B.root"]::String
_deref_bloberia(ref::BlobyRef) = Bloberia(_deref_bloberiapath(ref))

function _roothash_B!(ref::BlobyRef, h0 = UInt(0)) 
    h = hash(ref.link["B.root"], h0)
    return h
end

# public interface
deref(ref::BlobyRef{:Bloberia, Bloberia}) = _deref_bloberia(ref)
deref(B::Bloberia, ::BlobyRef{:Bloberia, Bloberia}) = B

deref_rootblob(ref::BlobyRef{:Bloberia, Bloberia}) = _deref_bloberia(ref)
deref_rootblob!(ref::BlobyRef{:Bloberia, Bloberia}) = _deref_bloberia(ref)

deref_roothash(ref::BlobyRef{:Bloberia, Bloberia}) = _roothash_B!(ref)

bloberia(ref::BlobyRef{:Bloberia, Bloberia}) = _deref_bloberia(ref)
blobbatch(::BlobyRef{:Bloberia, Bloberia}) = nothing

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# BlobBatch

# unsafe
_deref_batchpath(ref::BlobyRef) = _batchpath(_deref_bloberiapath(ref), ref.link["bb.id"]::String)
_deref_blobbatch(B::Bloberia, ref::BlobyRef) = blobbatch(B, ref.link["bb.id"]::String)
_deref_blobbatch(ref::BlobyRef) = _deref_blobbatch(_deref_bloberia(ref), ref)

_deref_blobbatch!(B::Bloberia, ref::BlobyRef) = blobbatch!(B, ref.link["bb.id"]::String)
_deref_blobbatch!(ref::BlobyRef) = _deref_blobbatch!(_deref_bloberia(ref), ref)

function _roothash_bb!(ref::BlobyRef, h0 = UInt(0)) 
    h = hash(ref.link["B.root"], h0)
    h = hash(ref.link["bb.id"], h)
    return h
end

# public interface
deref(ref::BlobyRef{:BlobBatch, BlobBatch}) = _deref_blobbatch(ref)
deref(bb::BlobBatch, ::BlobyRef{:BlobBatch, BlobBatch}) = bb
deref(B::Bloberia, ref::BlobyRef{:BlobBatch, BlobBatch}) = _deref_blobbatch(B, ref)

deref!(ref::BlobyRef{:BlobBatch, BlobBatch}) = _deref_blobbatch!(ref)
deref!(bb::BlobBatch, ::BlobyRef{:BlobBatch, BlobBatch}) = bb
deref!(B::Bloberia, ref::BlobyRef{:BlobBatch, BlobBatch}) = _deref_blobbatch!(B, ref)

deref_rootblob(ref::BlobyRef{:BlobBatch, BlobBatch}) = _deref_blobbatch(ref)
deref_rootblob!(ref::BlobyRef{:BlobBatch, BlobBatch}) = _deref_blobbatch!(ref)

deref_roothash(ref::BlobyRef{:BlobBatch, BlobBatch}) = _roothash_bb!(ref)

bloberia(ref::BlobyRef{:BlobBatch, BlobBatch}) = _deref_bloberia(ref)

blobbatch(ref::BlobyRef{:BlobBatch, BlobBatch}) = _deref_blobbatch(ref)
blobbatch!(ref::BlobyRef{:BlobBatch, BlobBatch}) = _deref_blobbatch!(ref)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Blob

# unsafe
_deref_blob(bb::BlobBatch, ref::BlobyRef) = blob(bb, ref.link["b.uuid"]::UInt128)
_deref_blob(B::Bloberia, ref::BlobyRef) = _deref_blob(_deref_blobbatch(B, ref), ref)
_deref_blob(ref::BlobyRef) = _deref_blob(_deref_blobbatch(ref), ref)

_deref_blob!(bb::BlobBatch, ref::BlobyRef) = blob!(bb, ref.link["b.uuid"]::UInt128)
_deref_blob!(B::Bloberia, ref::BlobyRef) = _deref_blob!(_deref_blobbatch(B, ref), ref)
_deref_blob!(ref::BlobyRef) = _deref_blob!(_deref_blobbatch!(ref), ref)


function _roothash_b!(ref::BlobyRef, h0 = UInt(0)) 
    h = _roothash_bb!(ref, h0)
    h = hash(ref.link["b.uuid"], h)
    return h
end

# public interface
deref(ref::BlobyRef{:Blob, Blob}) = _deref_blob(ref)
deref(b::Blob, ::BlobyRef{:Blob, Blob}) = b
deref(bb::BlobBatch, ref::BlobyRef{:Blob, Blob}) =  _deref_blob(bb, ref)
deref(B::Bloberia, ref::BlobyRef{:Blob, Blob}) =  _deref_blob(B, ref)

deref!(ref::BlobyRef{:Blob, Blob}) = _deref_blob!(ref)
deref!(bb::BlobBatch, ref::BlobyRef{:Blob, Blob}) =  _deref_blob!(bb, ref)
deref!(B::Bloberia, ref::BlobyRef{:Blob, Blob}) =  _deref_blob!(B, ref)
deref!(b::Blob, ::BlobyRef{:Blob, Blob}) = b

# the root blob is the original BlobyObject
deref_rootblob(ref::BlobyRef{:Blob, Blob}) = _deref_blob(ref)
deref_rootblob!(ref::BlobyRef{:Blob, Blob}) = _deref_blob!(ref)

deref_roothash(ref::BlobyRef{:Blob, Blob}) = _roothash_b!(ref)

bloberia(ref::BlobyRef{:Blob, Blob}) = _deref_bloberia(ref)
blobbatch(ref::BlobyRef{:Blob, Blob}) = _deref_blobbatch(ref)
blobbatch!(ref::BlobyRef{:Blob, Blob}) = _deref_blobbatch!(ref)
blob(ref::BlobyRef{:Blob, Blob}) = _deref_blob(ref)
blob!(ref::BlobyRef{:Blob, Blob}) = _deref_blob!(ref)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Val

# val owner
function __deref_valowner(ref::BlobyRef, _bconst, _bbconst, _Bconst)
    ow = get(ref.link, "val.owner", nothing)
    ow == "b" && return _bconst(ref)
    ow == "bb" && return _bbconst(ref)
    ow == "B" && return _Bconst(ref)
    error("Owner is missing!!")
end

# unsave
_deref_blobval(ow::AbstractBlob, ref::BlobyRef{lT, rT}) where rT where lT =
    getindex(ow, 
        ref.link["val.frame"]::String, 
        ref.link["val.key"]::String
    )::rT

_deref_blobval(ref::BlobyRef) = 
    _deref_blobval(deref_rootblob(ref), ref)
_deref_blobval!(ref::BlobyRef) = 
    _deref_blobval(deref_rootblob!(ref), ref)


# public interface
deref(ref::BlobyRef{:Val, rT}) where rT = _deref_blobval(ref)
deref!(ref::BlobyRef{:Val, rT}) where rT = _deref_blobval!(ref)
deref(b::Blob, ref::BlobyRef{:Val, rT}) where rT = _deref_blobval(b, ref)
deref(bb::BlobBatch, ref::BlobyRef{:Val, rT}) where rT = _deref_blobval(bb, ref)
deref(B::Bloberia, ref::BlobyRef{:Val, rT}) where rT = _deref_blobval(B, ref)

deref_rootblob(ref::BlobyRef{:Val, rT}) where rT =
    __deref_valowner(ref, blob, blobbatch, bloberia)
deref_rootblob!(ref::BlobyRef{:Val, rT}) where rT =
    __deref_valowner(ref, blob!, blobbatch!, bloberia)

deref_roothash(ref::BlobyRef{:Val, rT})  where rT =
    __deref_valowner(ref, _roothash_b!, _roothash_bb!, _roothash_B!)

bloberia(ref::BlobyRef{:Val, rT}) where rT = _deref_bloberia(ref)
blobbatch(ref::BlobyRef{:Val, rT}) where rT = _deref_blobbatch(ref)
blobbatch!(ref::BlobyRef{:Val, rT}) where rT = _deref_blobbatch!(ref)
blob(ref::BlobyRef{:Val, rT}) where rT = _deref_blob(ref)
blob!(ref::BlobyRef{:Val, rT}) where rT = _deref_blob!(ref)
    


# ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# # # BlobVal

# # # unsave
# # _deref_vblobval(b::Blob, ref::BlobyRef{lT, rT}) where rT where lT =
# #     getindex(b, ref.link["val.frame"], ref.link["val.key"])::rT
# # _deref_vblobval(bb::BlobBatch, ref::BlobyRef) =
# #     _deref_vblobval(_deref_blob(bb, ref), ref)
# # _deref_vblobval(B::Bloberia, ref::BlobyRef) =
# #     _deref_vblobval(_deref_blob(B, ref), ref)
# # _deref_vblobval(ref::BlobyRef) =
# #     _deref_vblobval(_deref_blob(ref), ref)

# # # public interface
# # deref(ref::BlobyRef{:BlobVal, rT}) where rT = _deref_vblobval(ref)
# # deref(b::Blob, ref::BlobyRef{:BlobVal, rT}) where rT = _deref_vblobval(b, ref)
# # deref(bb::BlobBatch, ref::BlobyRef{:BlobVal, rT}) where rT = _deref_vblobval(bb, ref)
# # deref(B::Bloberia, ref::BlobyRef{:BlobVal, rT}) where rT = _deref_vblobval(B, ref)

# # bloberia(ref::BlobyRef{:BlobVal, rT}) where rT = _deref_bloberia(ref)
# # blobbatch(ref::BlobyRef{:BlobVal, rT}) where rT = _deref_blobbatch(ref)
# # blob(ref::BlobyRef{:BlobVal, rT}) where rT  = _deref_blob(ref)

# # # --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# # # dBlob

# # # unsave
# # _deref_dblob(bb::BlobBatch, ::BlobyRef) = dblob(bb)
# # _deref_dblob(B::Bloberia, ref::BlobyRef) = _deref_dblob(_deref_blobbatch(B, ref), ref)
# # _deref_dblob(ref::BlobyRef) = _deref_dblob(_deref_blobbatch(ref), ref)

# # # public interface
# # deref(ref::BlobyRef{:dBlob, rT}) where rT = _deref_dblob(ref)
# # deref(db::dBlob, ::BlobyRef{:dBlob, rT}) where rT = db
# # deref(bb::BlobBatch, ref::BlobyRef{:dBlob, rT}) where rT = _deref_dblob(bb, ref)
# # deref(B::Bloberia, ref::BlobyRef{:dBlob, rT}) where rT = _deref_dblob(B, ref)

# # bloberia(ref::BlobyRef{:dBlob, dBlob}) = _deref_bloberia(ref)
# # blobbatch(ref::BlobyRef{:dBlob, dBlob}) = _deref_blobbatch(ref)
# # blob(ref::BlobyRef{:dBlob, dBlob}) = _deref_dblob(ref)


# # # --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# # # dBlobVal

# # # unsave
# # _deref_dblobval(db::dBlob, ref::BlobyRef{lT, rT}) where rT where lT =
# #     getindex(db, ref.link["db.frame"], ref.link["db.key"])::rT
# # _deref_dblobval(bb::BlobBatch, ref::BlobyRef) =
# #     _deref_dblobval(_deref_dblob(bb, ref), ref)
# # _deref_dblobval(B::Bloberia, ref::BlobyRef) =
# #     _deref_dblobval(_deref_dblob(B, ref), ref)
# # _deref_dblobval(ref::BlobyRef) =
# #     _deref_dblobval(_deref_dblob(ref), ref)


# # # public interface
# # deref(ref::BlobyRef{:dBlobVal, rT}) where rT = _deref_dblobval(ref)
# # deref(db::dBlob, ref::BlobyRef{:dBlobVal, rT}) where rT = _deref_dblobval(db, ref)
# # deref(bb::BlobBatch, ref::BlobyRef{:dBlobVal, rT}) where rT = _deref_dblobval(bb, ref)
# # deref(B::Bloberia, ref::BlobyRef{:dBlobVal, rT}) where rT = _deref_dblobval(B, ref)

# # bloberia(ref::BlobyRef{:dBlobVal, rT}) where rT = _deref_bloberia(ref)
# # blobbatch(ref::BlobyRef{:dBlobVal, rT}) where rT = _deref_blobbatch(ref)
# # dblob(ref::BlobyRef{:dBlobVal, rT}) where rT  = _deref_dblob(ref)
