## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Bloberia

# unsafe
_deref_bloberiapath(ref::BlobyRef) = ref.link["B.root"]::String
_deref_bloberia(ref::BlobyRef) = Bloberia(_deref_bloberiapath(ref))

# abs deref
deref(ref::BlobyRef{:Bloberia, Bloberia}) = _deref_bloberia(ref)
# deref relative to B
deref(B::Bloberia, ::BlobyRef{:Bloberia, Bloberia}) = B

bloberia(ref::BlobyRef{:Bloberia, Bloberia}) = _deref_bloberia(ref)
blobbatch(::BlobyRef{:Bloberia, Bloberia}) = nothing

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# BlobBatch

# unsafe
_deref_batchpath(ref::BlobyRef) = _batchpath(_deref_bloberiapath(ref),  ref.link["bb.id"])
_deref_blobbatch(B::Bloberia, ref::BlobyRef) = blobbatch(B, ref.link["bb.id"]::String)
_deref_blobbatch(ref::BlobyRef) = _deref_blobbatch(_deref_bloberia(ref), ref)

# public interface
deref(ref::BlobyRef{:BlobBatch, BlobBatch}) = _deref_blobbatch(ref)
deref(bb::BlobBatch, ::BlobyRef{:BlobBatch, BlobBatch}) = bb
deref(B::Bloberia, ref::BlobyRef{:BlobBatch, BlobBatch}) = _deref_blobbatch(B, ref)

bloberia(ref::BlobyRef{:BlobBatch, BlobBatch}) = _deref_bloberia(ref)
blobbatch(ref::BlobyRef{:BlobBatch, BlobBatch}) = _deref_blobbatch(ref)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Blob

# unsafe
_deref_vblob(bb::BlobBatch, ref::BlobyRef) = vblob(bb, ref.link["vb.uuid"]::UInt128)
_deref_vblob(B::Bloberia, ref::BlobyRef) = _deref_vblob(_deref_blobbatch(B, ref), ref)
_deref_vblob(ref::BlobyRef) = _deref_vblob(_deref_blobbatch(ref), ref)

# public interface
deref(ref::BlobyRef{:Blob, Blob}) = _deref_vblob(ref)
deref(vb::Blob, ::BlobyRef{:Blob, Blob}) =  vb
deref(bb::BlobBatch, ref::BlobyRef{:Blob, Blob}) =  _deref_vblob(bb, ref)
deref(B::Bloberia, ref::BlobyRef{:Blob, Blob}) =  _deref_vblob(B, ref)

bloberia(ref::BlobyRef{:Blob, Blob}) = _deref_bloberia(ref)
blobbatch(ref::BlobyRef{:Blob, Blob}) = _deref_blobbatch(ref)
vblob(ref::BlobyRef{:Blob, Blob}) = _deref_vblob(ref)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# TODO Move to Bloberia
# # BlobVal

# # unsave
# _deref_vblobval(vb::Blob, ref::BlobyRef{lT, rT}) where rT where lT =
#     getindex(vb, ref.link["vb.frame"]::String, ref.link["vb.key"]::String)::rT
# _deref_vblobval(bb::BlobBatch, ref::BlobyRef) =
#     _deref_vblobval(_deref_vblob(bb, ref), ref)
# _deref_vblobval(B::Bloberia, ref::BlobyRef) =
#     _deref_vblobval(_deref_vblob(B, ref), ref)
# _deref_vblobval(ref::BlobyRef) =
#     _deref_vblobval(_deref_vblob(ref), ref)

# # public interface
# deref(ref::BlobyRef{:BlobVal, rT}) where rT = _deref_vblobval(ref)
# deref(vb::Blob, ref::BlobyRef{:BlobVal, rT}) where rT = _deref_vblobval(vb, ref)
# deref(bb::BlobBatch, ref::BlobyRef{:BlobVal, rT}) where rT = _deref_vblobval(bb, ref)
# deref(B::Bloberia, ref::BlobyRef{:BlobVal, rT}) where rT = _deref_vblobval(B, ref)

# bloberia(ref::BlobyRef{:BlobVal, rT}) where rT = _deref_bloberia(ref)
# blobbatch(ref::BlobyRef{:BlobVal, rT}) where rT = _deref_blobbatch(ref)
# vblob(ref::BlobyRef{:BlobVal, rT}) where rT  = _deref_vblob(ref)

# # --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# # dBlob

# # unsave
# _deref_dblob(bb::BlobBatch, ::BlobyRef) = dblob(bb)
# _deref_dblob(B::Bloberia, ref::BlobyRef) = _deref_dblob(_deref_blobbatch(B, ref), ref)
# _deref_dblob(ref::BlobyRef) = _deref_dblob(_deref_blobbatch(ref), ref)

# # public interface
# deref(ref::BlobyRef{:dBlob, rT}) where rT = _deref_dblob(ref)
# deref(db::dBlob, ::BlobyRef{:dBlob, rT}) where rT = db
# deref(bb::BlobBatch, ref::BlobyRef{:dBlob, rT}) where rT = _deref_dblob(bb, ref)
# deref(B::Bloberia, ref::BlobyRef{:dBlob, rT}) where rT = _deref_dblob(B, ref)

# bloberia(ref::BlobyRef{:dBlob, dBlob}) = _deref_bloberia(ref)
# blobbatch(ref::BlobyRef{:dBlob, dBlob}) = _deref_blobbatch(ref)
# blob(ref::BlobyRef{:dBlob, dBlob}) = _deref_dblob(ref)


# # --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# # dBlobVal

# # unsave
# _deref_dblobval(db::dBlob, ref::BlobyRef{lT, rT}) where rT where lT =
#     getindex(db, ref.link["db.frame"]::String, ref.link["db.key"]::String)::rT
# _deref_dblobval(bb::BlobBatch, ref::BlobyRef) =
#     _deref_dblobval(_deref_dblob(bb, ref), ref)
# _deref_dblobval(B::Bloberia, ref::BlobyRef) =
#     _deref_dblobval(_deref_dblob(B, ref), ref)
# _deref_dblobval(ref::BlobyRef) =
#     _deref_dblobval(_deref_dblob(ref), ref)


# # public interface
# deref(ref::BlobyRef{:dBlobVal, rT}) where rT = _deref_dblobval(ref)
# deref(db::dBlob, ref::BlobyRef{:dBlobVal, rT}) where rT = _deref_dblobval(db, ref)
# deref(bb::BlobBatch, ref::BlobyRef{:dBlobVal, rT}) where rT = _deref_dblobval(bb, ref)
# deref(B::Bloberia, ref::BlobyRef{:dBlobVal, rT}) where rT = _deref_dblobval(B, ref)

# bloberia(ref::BlobyRef{:dBlobVal, rT}) where rT = _deref_bloberia(ref)
# blobbatch(ref::BlobyRef{:dBlobVal, rT}) where rT = _deref_blobbatch(ref)
# dblob(ref::BlobyRef{:dBlobVal, rT}) where rT  = _deref_dblob(ref)
