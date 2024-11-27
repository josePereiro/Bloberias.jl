getvframe(bb::BlobBatch) = bb.vframes
function getvframe(bb::BlobBatch, framekey::AbstractString)
    ondemand_loadvframe!(bb, framekey)
    return getindex(bb.vframes, framekey)
end
function getvframe!(bb::BlobBatch, framekey::AbstractString)
    ondemand_loadvframe!(bb, framekey)
    return get!(OrderedDict, bb.vframes, framekey)
end

getdframe(bb::BlobBatch) = bb.dframes
function getdframe(bb::BlobBatch, framekey::AbstractString)
    ondemand_loaddframe!(bb, framekey)
    return getindex(bb.dframes, framekey)
end
function getdframe!(bb::BlobBatch, framekey::AbstractString)
    ondemand_loaddframe!(bb, framekey)
    return get!(OrderedDict, bb.dframes, framekey)
end

function getvuuids(bb::BlobBatch)
    ondemand_loadvuuids!(bb)
    return bb.vuuids
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# hasframe
hasvframe_ram(bb::BlobBatch, frame) =
    haskey(bb.vframes, frame)
hasdframe_ram(bb::BlobBatch, frame) =
    haskey(bb.dframes, frame)
hasframe_ram(bb::BlobBatch, frame) =
    hasvframe_ram(bb, frame) || hasdframe_ram(bb, frame)

hasvframe_disk(bb::BlobBatch, frame) =
    isfile(vframe_jlspath(bb, frame))
hasdframe_disk(bb::BlobBatch, frame) =
    isfile(dframe_jlspath(bb, frame))
hasframe_disk(bb::BlobBatch, frame) =
    hasvframe_disk(bb, frame) || hasdframe_ram(bb, frame)

function hasframe(bb::BlobBatch, frame)
    hasframe_ram(bb, frame) && return true
    hasframe_disk(bb, frame) && return true
    return false
end