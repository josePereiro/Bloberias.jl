# ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# get an existing vblob
function vblob(bb::BlobBatch, i::Integer)
    ondemand_loadvuuids!(bb)
    return vBlob(bb, _getindex(bb.vuuids, i))
end

function vblob(bb::BlobBatch, uuid::UInt128)
    ondemand_loadvuuids!(bb)
    uuid ∈ bb.vuuids || error("Uuid ", repr(uuid), " not present")
    return vBlob(bb, uuid)
end

# registrer a new vblob if it does not exist
function vblob!(bb::BlobBatch, uuid::Integer)
    uuid = UInt128(uuid)
    ondemand_loadvuuids!(bb)
    b = vBlob(bb, uuid)
    uuid ∈ bb.vuuids && return b
    isopen(bb) || error("bb is closed!!!")
    push!(bb.vuuids, uuid)
    return b
end

# default blob
# vblob!(bb::BlobBatch) = vblob!(bb, 0)
# random new blob
rvblob!(bb::BlobBatch) = vblob!(bb, uuid_int())

# ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Use, uuids # RAM STATE
function vblobcount(bb::BlobBatch)
    ondemand_loadvuuids!(bb)
    return length(bb.vuuids)
end 
