## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# getframe
# load on demand each frame
function getframe(b::btBlob, frame::AbstractString)
    _ondemand_loaddat!(b.batch, frame) # loaded on batch
    return b.batch.frames[frame][b.uuid]
end

function getframe!(b::btBlob, frame::AbstractString)
    _ondemand_loaddat!(b.batch, frame) # loaded on batch
    _bb_frame = get!(OrderedDict, b.batch.frames, frame)
    _b_frame = get!(OrderedDict, _bb_frame, b.uuid)
    return _b_frame
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
hasframe(b::btBlob, frame::String) = hasframe(b.batch, frame)

# ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# # getframe
# # load on demand each frame
# function getframe(b::btBlob, frame::AbstractString)
#     _bb_frames = _ondemand_loaddat!(b.batch, frame) # loaded on batch
#     _bb_frame = getindex(_bb_frames, frame)
#     return getindex(_bb_frame, b.uuid)
# end

# function getframe!(b::btBlob, frame::AbstractString)
#     _bb_frames = _ondemand_loaddat!(b.batch, frame) # loaded on batch
#     _bb_frame = get!(OrderedDict, _bb_frames, frame)
#     _b_frame = get!(OrderedDict, _bb_frame, b.uuid)
#     return _b_frame
# end

# ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# hasframe(b::btBlob, frame::String) = hasframe(b.batch, frame)