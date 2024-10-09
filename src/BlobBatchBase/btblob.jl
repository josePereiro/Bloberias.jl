## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
function _getindex(os::OrderedSet, i0)
    for (i, v) in enumerate(os)
        i == i0 && return v
    end
    throw(BoundsError(s, i))
end

# get an existing blob
function blob(bb::BlobBatch, i::Integer)
    _ondemand_loaduuids!(bb)
    return btBlob(bb, _getindex(bb.uuids, i))
end

function blob(bb::BlobBatch, uuid::UInt128)
    _ondemand_loaduuids!(bb)
    uuid ∈ bb.uuids || error("Uuid ", repr(uuid), " not present")
    return btBlob(bb, uuid)
end

function blob!(bb::BlobBatch, uuid = uuid_int())
    _ondemand_loaduuids!(bb)
    b = btBlob(bb, uuid)
    push!(bb.uuids, uuid)
    return b
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Use, uuids # RAM STATE
blobcount(bb::BlobBatch) = length(getframe(bb, "uuids"))
