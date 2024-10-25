# random blobs

# return blob if exist in DISK
function blob(B::Bloberia, id::String)
    rb = raBlob(B, id)
    path = rablobpath(rb)
    isdir(path) || error("raBlob(\"", id, "\") not found.")
    return rb
end
blob(B::Bloberia) = blob(B, BLOBERIA_DEFAULT_RABLOB_ID)

# existing or new blob
# in practice an unchecked blob
function blob!(B::Bloberia, id::String)
    rb = raBlob(B, id)
    return rb
end
blob!(B::Bloberia) = blob!(B, BLOBERIA_DEFAULT_RABLOB_ID)
