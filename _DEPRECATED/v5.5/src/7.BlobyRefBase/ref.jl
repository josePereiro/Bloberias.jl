## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Bloberia

function upref!(ref::BlobyRef, B::Bloberia)
    ref.link["B.root"] = bloberiapath(B)
    return ref
end

# creates a ref to a Bloberia
function blobyref(B::Bloberia)
    ref = BlobyRef(:Bloberia, Bloberia)
    upref!(ref, B)
    return ref
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# BlobBatch
function upref!(ref::BlobyRef, bb::BlobBatch)
    ref.link["bb.id"] = bb.id
end

function blobyref(bb::BlobBatch)
    ref = BlobyRef(:BlobBatch, BlobBatch)
    upref!(ref, bb.B)
    upref!(ref, bb)
    return ref
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Blob

function upref!(ref::BlobyRef, vb::Blob, frame, key)
    ref.link["vb.uuid"] = vb.uuid
    ref.link["vb.frame"] = frame
    ref.link["vb.key"] = key
end

# :Blob
function blobyref(vb::Blob)
    ref = BlobyRef(:Blob, Blob)
    upref!(ref, vb.bb.B)
    upref!(ref, vb.bb)
    upref!(ref, vb, nothing, nothing)
    return ref
end

# :BlobVal
function blobyref(vb::Blob, frame, key, rT = Any)
    ref = BlobyRef(:BlobVal, rT)
    upref!(ref, vb.bb.B)
    upref!(ref, vb.bb)
    upref!(ref, vb, frame, key)
    return ref
end

# # --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# TODO: reimplement using bb
# # dBlob
# function upref!(ref::BlobyRef, ::dBlob, frame, key)
#     ref.link["db.frame"] = frame
#     ref.link["db.key"] = key
# end

# function blobyref(db::dBlob)
#     ref = BlobyRef(:dBlob, dBlob)
#     upref!(ref, db.bb.B)
#     upref!(ref, db.bb)
#     upref!(ref, db, nothing, nothing)
#     return ref
# end

# function blobyref(db::dBlob, frame, key, rT = Any)
#     ref = BlobyRef(:dBlobVal, rT)
#     upref!(ref, db.bb.B)
#     upref!(ref, db.bb)
#     upref!(ref, db, frame, key)
#     return ref
# end

