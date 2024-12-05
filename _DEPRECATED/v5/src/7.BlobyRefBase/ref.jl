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
# vBlob

function upref!(ref::BlobyRef, vb::vBlob, frame, key)
    ref.link["vb.uuid"] = vb.uuid
    ref.link["vb.frame"] = frame
    ref.link["vb.key"] = key
end

# :vBlob
function blobyref(vb::vBlob)
    ref = BlobyRef(:vBlob, vBlob)
    upref!(ref, vb.bb.B)
    upref!(ref, vb.bb)
    upref!(ref, vb, nothing, nothing)
    return ref
end

# :vBlobVal
function blobyref(vb::vBlob, frame, key; rT = nothing)
    if isnothing(rT)
        val = getindex(vb, frame, key)
        rT = typeof(val)
    end
    ref = BlobyRef(:vBlobVal, rT)
    upref!(ref, vb.bb.B)
    upref!(ref, vb.bb)
    upref!(ref, vb, frame, key)
    return ref
end

# --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# dBlob
function upref!(ref::BlobyRef, ::dBlob, frame, key)
    ref.link["db.frame"] = frame
    ref.link["db.key"] = key
end

function blobyref(db::dBlob)
    ref = BlobyRef(:dBlob, dBlob)
    upref!(ref, db.bb.B)
    upref!(ref, db.bb)
    upref!(ref, db, nothing, nothing)
    return ref
end

function blobyref(db::dBlob, frame, key; rT = nothing)
    if isnothing(rT)
        val = getindex(db, frame, key)
        rT = typeof(val)
    end
    ref = BlobyRef(:dBlobVal, rT)
    upref!(ref, db.bb.B)
    upref!(ref, db.bb)
    upref!(ref, db, frame, key)
    return ref
end

