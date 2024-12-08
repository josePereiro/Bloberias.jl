## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# getframe interface
# - load a frame if the ram version is missing
# - otherwise return the ram version
# - bang versions creates the ram frame if it is missing

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
getbframes(bb::BlobBatch) = bb.bframes
function getbframe(bb::BlobBatch, framekey::AbstractString)
    ondemand_loadbframe!(bb, framekey)
    return getindex(bb.bframes, framekey)
end
getbframe!(bb::BlobBatch) = getbframe!(bb, BLOBBATCH_DEFAULT_FRAME_NAME)
function getbframe!(bb::BlobBatch, framekey::AbstractString)
    ondemand_loadbframe!(bb, framekey)
    return get!(OrderedDict, bb.bframes, framekey)
end
getbframe(bb::BlobBatch) = getbframe(bb, BLOBBATCH_DEFAULT_FRAME_NAME)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
getbbframes(bb::BlobBatch) = bb.bbframes
function getbbframe(bb::BlobBatch, framekey::AbstractString)
    ondemand_loadbbframe!(bb, framekey)
    return getindex(bb.bbframes, framekey)
end
getbbframe(bb::BlobBatch) = getbbframe(bb, BLOBBATCH_DEFAULT_FRAME_NAME)

function getbbframe!(bb::BlobBatch, framekey::AbstractString)
    ondemand_loadbbframe!(bb, framekey)
    return get!(OrderedDict, bb.bbframes, framekey)
end
getbbframe!(bb::BlobBatch) = getbbframe!(bb, BLOBBATCH_DEFAULT_FRAME_NAME)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
function getframe(bb::BlobBatch, frame::AbstractString)
    ondemand_loadbbframe!(bb, frame)
    return getindex(bb.bbframes, frame)
end

function getframe!(bb::BlobBatch, frame::AbstractString)
    ondemand_loadbbframe!(bb, frame) # loaded on batch
    _frame = get!(OrderedDict, bb.bbframes, frame)
    return _frame
end

getframes(bb::BlobBatch) = bb.bbframes

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
function getbuuids(bb::BlobBatch)
    ondemand_loadbuuids!(bb)
    return bb.buuids
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# hasframe
hasbframe_ram(bb::BlobBatch, frame) =
    haskey(bb.bframes, frame)
hasbbframe_ram(bb::BlobBatch, frame) =
    haskey(bb.bbframes, frame)

hasbframe_disk(bb::BlobBatch, frame) =
    isfile(bframe_jlspath(bb, frame))
hasbbframe_disk(bb::BlobBatch, frame) =
    isfile(bbframe_jlspath(bb, frame))

hasbframe(bb::BlobBatch, frame) =
    hasbframe_ram(bb, frame) || hasbframe_ram(bb, frame)
hasbbframe(bb::BlobBatch, frame) =
    hasbbframe_ram(bb, frame) || hasbbframe_ram(bb, frame)

function hasframe(bb::BlobBatch, frame)
    hasbframe_ram(bb, frame) && return true
    hasbbframe_ram(bb, frame) && return true
    hasbframe_disk(bb, frame) && return true
    hasbbframe_disk(bb, frame) && return true
    return false
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 