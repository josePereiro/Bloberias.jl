## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Bloberia

function upref!(ref::BlobyRef, B::Bloberia, frame, key)
    ref.link["B.root"] = bloberiapath(B)
    isnothing(frame) && return ref
    ref.link["val.frame"] = frame
    ref.link["val.key"] = key
    ref.link["val.owner"] = "B"
    return ref
end

# creates a ref to a Bloberia
function blobyref(B::Bloberia)
    ref = BlobyRef(:Bloberia, Bloberia)
    upref!(ref, B, nothing, nothing)
    return ref
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# BlobBatch
function upref!(ref::BlobyRef, bb::BlobBatch, frame, key)
    ref.link["bb.id"] = bb.id
    isnothing(frame) && return ref
    ref.link["val.frame"] = frame
    ref.link["val.key"] = key
    ref.link["val.owner"] = "bb"
    return ref
end

function blobyref(bb::BlobBatch)
    ref = BlobyRef(:BlobBatch, BlobBatch)
    upref!(ref, bb.B, nothing, nothing)
    upref!(ref, bb, nothing, nothing)
    return ref
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Blob

function upref!(ref::BlobyRef, b::Blob, frame, key)
    ref.link["b.uuid"] = b.uuid
    isnothing(frame) && return ref
    ref.link["val.frame"] = frame
    ref.link["val.key"] = key
    ref.link["val.owner"] = "b"
    return ref
end

# :Blob
function blobyref(b::Blob)
    ref = BlobyRef(:Blob, Blob)
    upref!(ref, b.bb.B, nothing, nothing)
    upref!(ref, b.bb, nothing, nothing)
    upref!(ref, b, nothing, nothing)
    return ref
end

# --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# :Val

function blobyref(B::Bloberia, frame, key; rT = Any)
    ref = BlobyRef(:Val, rT)
    upref!(ref, B, frame, key)
    return ref
end

function blobyref(bb::BlobBatch, frame, key; rT = Any)
    ref = BlobyRef(:Val, rT)
    upref!(ref, bb.B, nothing, nothing)
    upref!(ref, bb, frame, key)
    return ref
end

function blobyref(b::Blob, frame, key; rT = Any)
    ref = BlobyRef(:Val, rT)
    upref!(ref, b.bb.B, nothing, nothing)
    upref!(ref, b.bb, nothing, nothing)
    upref!(ref, b, frame, key)
    return ref
end
