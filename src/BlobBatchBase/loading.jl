## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# load frame from disk if file exist, overwrite ram data 

_force_loadtemp!(::BlobBatch) = nothing

function _force_loaduuids!(bb::BlobBatch)
    _frame_dat = _trydeserialize(uuids_framepath(bb))
    isnothing(_frame_dat) && return nothing
    bb.uuids = _frame_dat
    return nothing
end

function _force_loadmeta!(bb::BlobBatch)
    _frame_dat = _trydeserialize(meta_framepath(bb))
    isnothing(_frame_dat) && return nothing
    bb.meta = _frame_dat
    return nothing
end

function _force_loaddat!(bb::BlobBatch, frame)
    _frame_dat = _trydeserialize(dat_framepath(bb, frame))
    isnothing(_frame_dat) && return nothing
    setindex!(bb.frames, _frame_dat, frame)
    return nothing
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# different to loadframe!
# only load if RAM frame is empty or missing

_ondemand_loadtemp!(::BlobBatch) = nothing

function _ondemand_loaduuids!(bb::BlobBatch)
    isempty(bb.uuids) && _force_loaduuids!(bb)
    return nothing
end

function _ondemand_loadmeta!(bb::BlobBatch)
    isempty(bb.meta) && _force_loadmeta!(bb)
    return nothing
end

function _ondemand_loaddat!(bb::BlobBatch, frame)
    !haskey(bb.frames, frame) && (_force_loaddat!(bb, frame); return)
    isempty(bb.frames[frame]) && _force_loaddat!(bb, frame)
    return nothing
end
