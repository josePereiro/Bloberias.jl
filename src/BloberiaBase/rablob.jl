# random blobs

# create 

# return blob if exist in RAM or DISK
function rablob(B::Bloberia, id::String)
    B.rablob_id == id && return raBlob(B, id)
    path = rablob_framepath(B, id)
    isfile(path) || error("raBlob(\"", id, "\") not found.")
    return raBlob(B, id)
end

# existing or new blob
# in practice an unchecked blob
function rablob!(B::Bloberia, id::String)
    _ondemand_loadrablob!(B, id)
    return raBlob(B, id)
end
rablob!(B::Bloberia) = rablob!(B, BLOBERIA_DEFAULT_RABLOB_ID)
