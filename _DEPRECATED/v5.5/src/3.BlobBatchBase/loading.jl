## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# force_load interface
# - load disk version

_force_loadtemp!(::BlobBatch) = nothing

function force_loadbuuids!(bb::BlobBatch)
    _frame_dat = _trydeserialize(buuids_jlspath(bb))
    isnothing(_frame_dat) && return nothing
    isempty(_frame_dat) && return nothing
    push!(bb.buuids, _frame_dat...)
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
        _bframe = bb_frames[framekey]
        empty!(_bframe)
        push!(_bframe, _frame_dat...)
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

force_loadbframes!(bb::BlobBatch) = 
    _bb_force_load_all_datframes!(bb.bframes, batchpath(bb), ".bframe.jls")
force_loadbframe!(bb::BlobBatch, framekey) =
    _bb_force_load_datframe!(bb.bframes, bframe_jlspath(bb, framekey), framekey)

force_loadbbframes!(bb::BlobBatch) =
    _bb_force_load_all_datframes!(bb.bbframes, batchpath(bb), ".bbframe.jls")
force_loadbbframe!(bb::BlobBatch, framekey) =
    _bb_force_load_datframe!(bb.bbframes, bbframe_jlspath(bb, framekey), framekey)

function force_loadbatch(bb::BlobBatch)
    force_loadmeta!(bb)
    force_loadbuuids!(bb)
    force_loadbframes!(bb)
    force_loadbbframes!(bb)
    return nothing
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# ondemand_load interface
# - load if ram version is empty and return
# - return ram if non empty
# - return nothing if both missing

_ondemand_loadtemp!(::BlobBatch) = nothing

function ondemand_loadbuuids!(bb::BlobBatch)
    isempty(bb.buuids) && force_loadbuuids!(bb)
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

function ondemand_loadbframe!(bb::BlobBatch, framekey)
    ondemand_loadbuuids!(bb)
    _is_empty_frame(bb.bframes, framekey) && force_loadbframe!(bb, framekey)
    return nothing
end
function ondemand_loadbbframe!(bb::BlobBatch, framekey)
    _is_empty_frame(bb.bbframes, framekey) && force_loadbbframe!(bb, framekey)
    return nothing
end

