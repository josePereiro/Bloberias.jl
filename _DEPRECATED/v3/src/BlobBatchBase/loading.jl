## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# load frame from disk if file exist, overwrite ram data 

_force_loadtemp!(::BlobBatch) = nothing

function _force_loaduuids!(bb::BlobBatch)
    frame = _trydeserialize(uuids_framepath(bb))
    isnothing(frame) && return nothing
    bb.uuids = frame
    return nothing
end

function _force_loadmeta!(bb::BlobBatch)
    frame = _trydeserialize(meta_framepath(bb))
    isnothing(frame) && return nothing
    bb.meta = frame
    return nothing
end

function _force_loadlite!(bb::BlobBatch)
    frame = _trydeserialize(lite_framepath(bb))
    isnothing(frame) && return nothing
    bb.lite = frame
    return nothing
end

function _force_loadnonlite!(bb::BlobBatch, group)
    frame = _trydeserialize(nonlite_framepath(bb, group))
    isnothing(frame) && return nothing
    _group = get!(OrderedDict, bb.nonlite, group)
    _group[group] = frame
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

function _ondemand_loadlite!(bb::BlobBatch)
    isempty(bb.lite) && _force_loadlite!(bb)
    return nothing
end

function _ondemand_loadnonlite!(bb::BlobBatch, group)
    !haskey(bb.nonlite, group) && return _force_loadnonlite!(bb, group)
    isempty(bb.nonlite[group]) && _force_loadnonlite!(bb, group)
    return nothing
end
