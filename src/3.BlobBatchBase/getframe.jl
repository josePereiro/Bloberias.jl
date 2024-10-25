function getframe(bb::BlobBatch, frame::AbstractString)
    frame == "temp" && return bb.temp
    if frame == "meta" 
        _ondemand_loadmeta!(bb)
        return bb.meta
    end
    if frame == "uuids"
        _ondemand_loaduuids!(bb)
        return bb.uuids
    end
    _ondemand_loaddat!(bb, frame)
    return bb.frames[frame]
end
getframe(bb::BlobBatch) = getframe(bb, BLOBERIA_DEFAULT_FRAME_NAME)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# hasframe
function hasframe_ram(bb::BlobBatch, frame)
    # check ram
    frame == "temp" && return true
    frame == "meta" && return true
    haskey(bb.frames, frame) && return true
    return false
end

function hasframe_disk(bb::BlobBatch, frame)
    frame == "temp" && return false
    if frame == "meta" 
        _file = meta_framepath(bb)
        return isfile(_file)
    end
    _file = dat_framepath(bb, frame)
    return isfile(_file)
end

function hasframe(bb::BlobBatch, frame)
    hasframe_ram(bb, frame) && return true
    hasframe_disk(bb, frame) && return true
    return false
end