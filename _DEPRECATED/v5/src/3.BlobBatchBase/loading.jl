## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# force_load interface
# - load disk version

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


function _bb_force_load_all_datframes!(bb_frames, bb_root, jls_tail)
    files = readdir(bb_root; join = false)
    for file in files
        endswith(file, jls_tail) || continue
        frame = replace(file, jls_tail => "")
        path = joinpath(bb_root, file)
        _bb_force_load_datframe!(bb_frames, path, frame)
    end
    return nothing
end

force_loadvframes!(bb::BlobBatch) = 
    _bb_force_load_all_datframes!(bb.vframes, batchpath(bb), ".vframe.jls")
force_loadvframe!(bb::BlobBatch, framekey) =
    _bb_force_load_datframe!(bb.vframes, vframe_jlspath(bb, framekey), framekey)

force_loaddframes!(bb::BlobBatch) =
    _bb_force_load_all_datframes!(bb.dframes, batchpath(bb), ".dframe.jls")
force_loaddframe!(bb::BlobBatch, framekey) =
    _bb_force_load_datframe!(bb.dframes, dframe_jlspath(bb, framekey), framekey)

function force_loadbatch(bb::BlobBatch)
    force_loadmeta!(bb)
    force_loadvuuids!(bb)
    force_loadvframes!(bb)
    force_loaddframes!(bb)
    return nothing
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# ondemand_load interface
# - load if ram version is empty and return
# - return ram if non empty
# - return nothing if both missing

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
    ondemand_loadvuuids!(bb)
    _is_empty_frame(bb.vframes, framekey) && force_loadvframe!(bb, framekey)
    return nothing
end
function ondemand_loaddframe!(bb::BlobBatch, framekey)
    _is_empty_frame(bb.dframes, framekey) && force_loaddframe!(bb, framekey)
    return nothing
end

