## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# get a new blob
function blob(bb::BlobBatch, uuid = uuid_int())
    _ondemand_loaduuids!(bb)
    b = Blob(bb, uuid)
    push!(bb.uuids, b.uuid)
    return b
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Use, uuids
function blobcount(bb::BlobBatch)
    _ondemand_loaduuids!(bb)
    return length(bb.uuids)
end