function getframe(rb::raBlob, frame::AbstractString)
    frame == "temp" && return bb.temp
    if frame == "meta"
        _ondemand_loadmeta!(rb)
        return rb.meta
    end
    _ondemand_loaddat!(rb, frame)
    return rb.frames[frame]
end
getframe(rb::raBlob) = getframe(rb, BLOBERIA_DEFAULT_FRAME_NAME)

function getframe!(rb::raBlob, frame::AbstractString)
    _ondemand_loaddat!(rb, frame) # loaded on batch
    _frame = get!(OrderedDict, rb.frames, frame)
    return _frame
end
getframe!(rb::raBlob) = getframe!(rb, BLOBBATCH_DEFAULT_FRAME_NAME)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# hasframe
function hasframe_ram(rb::raBlob, frame)
    # check ram
    frame == "temp" && return true
    frame == "meta" && return true
    haskey(rb.frames, frame) && return true
    return false
end

function hasframe_disk(rb::raBlob, frame)
    frame == "temp" && return false
    if frame == "meta" 
        _file = meta_framepath(rb)
        return isfile(_file)
    end
    _file = dat_framepath(rb, frame)
    return isfile(_file)
end

function hasframe(rb::raBlob, frame)
    hasframe_ram(rb, frame) && return true
    hasframe_disk(rb, frame) && return true
    return false
end