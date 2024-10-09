# random blobs

# return blob if exist in DISK
function blob(B::Bloberia, id::String)
    rb = raBlob(B, id)
    path = rablob_framepath(rb)
    isfile(path) || error("raBlob(\"", id, "\") not found.")
    return rb
end
blob(B::Bloberia) = blob(B, BLOBERIA_DEFAULT_RABLOB_ID)

# existing or new blob
# in practice an unchecked blob
function blob!(B::Bloberia, id::String)
    rb = raBlob(B, id)
    _ondemand_loadrablob!(rb)
    return rb
end
blob!(B::Bloberia) = blob!(B, BLOBERIA_DEFAULT_RABLOB_ID)
