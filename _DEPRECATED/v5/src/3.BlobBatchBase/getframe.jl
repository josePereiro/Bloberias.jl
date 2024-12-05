## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# getframe interface
# - load a frame if the ram version is empty
# - otherwise return the ram version
# - bang versions creates the ram frame if it is missing

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
getvframes(bb::BlobBatch) = bb.vframes
function getvframe(bb::BlobBatch, framekey::AbstractString)
    ondemand_loadvframe!(bb, framekey)
    return getindex(bb.vframes, framekey)
end
getvframe!(bb::BlobBatch) = getvframe!(bb, BLOBBATCH_DEFAULT_FRAME_NAME)
function getvframe!(bb::BlobBatch, framekey::AbstractString)
    ondemand_loadvframe!(bb, framekey)
    return get!(OrderedDict, bb.vframes, framekey)
end
getvframe(bb::BlobBatch) = getvframe(bb, BLOBBATCH_DEFAULT_FRAME_NAME)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
getdframes(bb::BlobBatch) = bb.dframes
function getdframe(bb::BlobBatch, framekey::AbstractString)
    ondemand_loaddframe!(bb, framekey)
    return getindex(bb.dframes, framekey)
end
getdframe(bb::BlobBatch) = getdframe(bb, BLOBBATCH_DEFAULT_FRAME_NAME)

function getdframe!(bb::BlobBatch, framekey::AbstractString)
    ondemand_loaddframe!(bb, framekey)
    return get!(OrderedDict, bb.dframes, framekey)
end
getdframe!(bb::BlobBatch) = getdframe!(bb, BLOBBATCH_DEFAULT_FRAME_NAME)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
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

hasvframe_disk(bb::BlobBatch, frame) =
    isfile(vframe_jlspath(bb, frame))
hasdframe_disk(bb::BlobBatch, frame) =
    isfile(dframe_jlspath(bb, frame))

hasvframe(bb::BlobBatch, frame) =
    hasvframe_ram(bb, frame) || hasvframe_ram(bb, frame)
hasdframe(bb::BlobBatch, frame) =
    hasdframe_ram(bb, frame) || hasdframe_ram(bb, frame)

function hasframe(bb::BlobBatch, frame)
    hasvframe_ram(bb, frame) && return true
    hasdframe_ram(bb, frame) && return true
    hasvframe_disk(bb, frame) && return true
    hasdframe_disk(bb, frame) && return true
    return false
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 