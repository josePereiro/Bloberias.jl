## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# load frame from disk if file exist, overwrite ram data 

_force_loadtemp!(::BlobBatch) = nothing

function _force_loaduuids!(bb::BlobBatch)
    _frame_dat = _trydeserialize(uuids_framepath(bb))
    isnothing(_frame_dat) && return nothing
    isempty(_frame_dat) && return nothing
    push!(bb.uuids, _frame_dat...)
    return nothing
end

function _force_loadmeta!(bb::BlobBatch)
    _frame_dat = _trydeserialize(meta_framepath(bb))
    isnothing(_frame_dat) && return nothing
    merge!(bb.meta, _frame_dat)
    return nothing
end

function _force_loaddat!(bb::BlobBatch, frame)
    _frame_dat = _trydeserialize(dat_framepath(bb, frame))
    isnothing(_frame_dat) && return nothing
    setindex!(bb.frames, _frame_dat, frame)
    return nothing
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
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


# ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# # load frame from disk if file exist, overwrite ram data 

# _force_loadtemp!(::BlobBatch) = nothing

# function _force_loaduuids!(bb::BlobBatch)
#     _frame_dat = _trydeserialize(uuids_framepath(bb))
#     isnothing(_frame_dat) && return bb.uuids
#     isempty(_frame_dat) && return bb.uuids
#     push!(bb.uuids, _frame_dat...)
#     return bb.uuids
# end

# function _force_loadmeta!(bb::BlobBatch)
#     _frame_dat = _trydeserialize(meta_framepath(bb))
#     isnothing(_frame_dat) && return bb.meta
#     merge!(bb.meta, _frame_dat)
#     return bb.meta
# end

# function _force_loaddat!(bb::BlobBatch, frame)
#     _frame_dat = _trydeserialize(dat_framepath(bb, frame))
#     isnothing(_frame_dat) && return nothing
#     setindex!(bb.frames, _frame_dat, frame)
#     return _frame_dat
# end

# ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# # only load if RAM frame is empty or missing

# _ondemand_loadtemp!(::BlobBatch) = nothing

# function _ondemand_loaduuids!(bb::BlobBatch)
#     isempty(bb.uuids) && _force_loaduuids!(bb)
#     return bb.uuids
# end

# function _ondemand_loadmeta!(bb::BlobBatch)
#     isempty(bb.meta) && _force_loadmeta!(bb)
#     return bb.meta
# end

# function _ondemand_loaddat!(bb::BlobBatch, frame)
#     _ram_missed = !haskey(bb.frames, frame) || isempty(bb.frames[frame])
#     _ram_missed && _force_loaddat!(bb, frame)
#     return getindex(bb.frames, frame)
# end


