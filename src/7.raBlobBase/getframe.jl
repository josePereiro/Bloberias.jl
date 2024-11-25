function getframe(rb::raBlob, frame::AbstractString)
    frame == "temp" && return bb.temp
    if frame == "meta"
        _ondemand_loadmeta!(rb)
        return rb.meta
    end
    _ondemand_loaddat!(rb, frame)
    return getindex(rb.frames, frame)
end

function getframe!(rb::raBlob, frame::AbstractString)
    _ondemand_loaddat!(rb, frame) # loaded on batch
    _frame = get!(OrderedDict, rb.frames, frame)
    return _frame
end

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
    frame == "meta" && isfile(meta_framepath(rb))
    isfile(dat_framepath(rb, frame)) && return true
    return false
end

function hasframe(rb::raBlob, frame)
    hasframe_ram(rb, frame) && return true
    hasframe_disk(rb, frame) && return true
    return false
end