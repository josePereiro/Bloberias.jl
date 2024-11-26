## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# load frame from disk if file exist, overwrite ram data 

_force_loadtemp!(::BlobBatch) = nothing

function force_loadvuuids!(bb::BlobBatch)
    _frame_dat = _trydeserialize(vuuids_jlspath(bb))
    isnothing(_frame_dat) && return nothing
    isempty(_frame_dat) && return nothing
    push!(bb.vuuids, _frame_dat...)
    return nothing
end

function force_loadmeta!(bb::BlobBatch)
    _frame_dat = _trydeserialize(meta_jlspath(bb))
    isnothing(_frame_dat) && return nothing
    merge!(bb.meta, _frame_dat)
    return nothing
end

function _bb_force_load_datframe!(bb_frames, path, framekey)
    _frame_dat = _trydeserialize(path)
    isnothing(_frame_dat) && return nothing
    if haskey(bb_frames, framekey)
        # keep the same object
        _vframe = bb_frames[framekey]
        empty!(_vframe)
        push!(_vframe, _frame_dat...)
    else
        # keep new object
        setindex!(bb_frames, _frame_dat, framekey)
    end
    return nothing
end

function force_loadvframe!(bb::BlobBatch, framekey)
    _bb_force_load_datframe!(bb.vframes, vframe_jlspath(bb, framekey), framekey)
end
function force_loaddframe!(bb::BlobBatch, framekey)
    _bb_force_load_datframe!(bb.dframes, dframe_jlspath(bb, framekey), framekey)
end


## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# only load if RAM frame is empty or missing

_ondemand_loadtemp!(::BlobBatch) = nothing

function ondemand_loadvuuids!(bb::BlobBatch)
    isempty(bb.vuuids) && force_loadvuuids!(bb)
    return nothing
end

function ondemand_loadmeta!(bb::BlobBatch)
    isempty(bb.meta) && force_loadmeta!(bb)
    return nothing
end

function _is_empty_frame(frames, key)
    isempty(frames) && return true
    !haskey(frames, key) && return true
    isempty(frames[key]) && return true
    return false
end

function ondemand_loadvframe!(bb::BlobBatch, framekey)
    _is_empty_frame(bb.vframes, framekey) && force_loadvframe!(bb, framekey)
    return nothing
end
function ondemand_loaddframe!(bb::BlobBatch, framekey)
    _is_empty_frame(bb.dframes, framekey) && force_loaddframe!(bb, framekey)
    return nothing
end

