# ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# get an existing vblob
function vblob(bb::BlobBatch, uuid::Integer)
    vuuids = getvuuids(bb)
    uuid ∈ vuuids || error("Uuid ", repr(uuid), " not present")
    return vBlob(bb, uuid)
end

# registrer a new vblob if it does not exist
function vblob!(bb::BlobBatch, uuid::Integer)
    uuid = UInt128(uuid)
    b = vBlob(bb, uuid)
    vuuids = getvuuids(bb)
    uuid ∈ vuuids && return b
    isfullbatch(bb) && error("The batch is full, see 'vblobcount' and 'vbloblim'")
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
    vuuids = getvuuids(bb)
    return length(vuuids)
end 
