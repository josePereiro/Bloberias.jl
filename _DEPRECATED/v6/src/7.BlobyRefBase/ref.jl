## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Bloberia

function upref!(ref::BlobyRef, B::Bloberia, frame, key)
    ref.link["B.root"] = bloberiapath(B)
    isnothing(frame) && return ref
    ref.link["val.frame"] = frame
    ref.link["val.key"] = key
    return ref
end

# creates a ref to a Bloberia
function blobyref(B::Bloberia; abs = true)
    ref = BlobyRef(:Bloberia, Bloberia)
    upref!(ref, B, nothing, nothing)
    ref.link["src"] = "B"
    return ref
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# BlobBatch
function upref!(ref::BlobyRef, bb::BlobBatch, frame, key)
    ref.link["bb.id"] = bb.id
    isnothing(frame) && return ref
    ref.link["val.frame"] = frame
    ref.link["val.key"] = key
    return ref
end

function blobyref(bb::BlobBatch; abs = true)
    ref = BlobyRef(:BlobBatch, BlobBatch)
    abs && upref!(ref, bb.B, nothing, nothing)
    upref!(ref, bb, nothing, nothing)
    ref.link["src"] = "bb"
    return ref
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Blob

function upref!(ref::BlobyRef, b::Blob, frame, key)
    ref.link["b.uuid"] = b.uuid
    isnothing(frame) && return ref
    ref.link["val.frame"] = frame
    ref.link["val.key"] = key
    return ref
end

# :Blob
function blobyref(b::Blob; abs = true)
    ref = BlobyRef(:Blob, Blob)
    abs && upref!(ref, b.bb.B, nothing, nothing)
    abs && upref!(ref, b.bb, nothing, nothing)
    upref!(ref, b, nothing, nothing)
    ref.link["src"] = "b"
    return ref
end

# --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# :Val

function blobyref(B::Bloberia, frame, key; rT = Any, abs = true)
    ref = BlobyRef(:Val, rT)
    upref!(ref, B, frame, key)
    ref.link["src"] = "B"
    return ref
end

function blobyref(bb::BlobBatch, frame, key; rT = Any, abs = true)
    ref = BlobyRef(:Val, rT)
    abs && upref!(ref, bb.B, nothing, nothing)
    upref!(ref, bb, frame, key)
    ref.link["src"] = "bb"
    return ref
end

function blobyref(b::Blob, frame, key; rT = Any, abs = true)
    ref = BlobyRef(:Val, rT)
    abs && upref!(ref, b.bb.B, nothing, nothing)
    abs && upref!(ref, b.bb, nothing, nothing)
    upref!(ref, b, frame, key)
    ref.link["src"] = "b"
    return ref
end
