# ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# get an existing vblob
function vblob(bb::BlobBatch, uuid::Integer)
    buuids = getbuuids(bb)
    uuid ∈ buuids || error("Uuid ", repr(uuid), " not present")
    return Blob(bb, uuid)
end

# registrer a new vblob if it does not exist
function vblob!(bb::BlobBatch, uuid::Integer)
    uuid = UInt128(uuid)
    b = Blob(bb, uuid)
    buuids = getbuuids(bb)
    uuid ∈ buuids && return b
    isfullbatch(bb) && error("The batch is full, see 'vblobcount' and 'vbloblim'")
    push!(bb.buuids, uuid)
    return b
end

# default blob
# vblob!(bb::BlobBatch) = vblob!(bb, 0)
# random new blob
rblob!(bb::BlobBatch) = vblob!(bb, uuid_int())

# ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Use, uuids # RAM STATE
function vblobcount(bb::BlobBatch)
    buuids = getbuuids(bb)
    return length(buuids)
end 
