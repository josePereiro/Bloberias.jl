## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# load rab (random access blobs) is the file exists

function _force_loadmeta!(rb::raBlob)
    _frame_dat = _trydeserialize(meta_framepath(rb))
    isnothing(_frame_dat) && return nothing
    merge!(rb.meta, _frame_dat)
    return nothing
end

function _force_loaddat!(rb::raBlob, frame)
    _frame_dat = _trydeserialize(dat_framepath(rb, frame))
    isnothing(_frame_dat) && return nothing
    setindex!(rb.frames, _frame_dat, frame)
    return nothing
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
function _ondemand_loadmeta!(rb::raBlob)
    isempty(rb.meta) && _force_loadmeta!(rb)
    return nothing
end

function _ondemand_loaddat!(rb::raBlob, frame)
    !haskey(rb.frames, frame) && (_force_loaddat!(rb, frame); return)
    isempty(rb.frames[frame]) && _force_loaddat!(rb, frame)
    return nothing
end