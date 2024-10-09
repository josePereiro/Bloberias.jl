## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# getframe
# load on demand each frame
function getframe(b::btBlob, frame::AbstractString)
    _ondemand_loaddat!(b.batch, frame) # loaded on batch
    return b.batch.frames[frame][b.uuid]
end
getframe(b::btBlob) = getframe(b, BLOBBATCH_DEFAULT_FRAME_NAME)

function getframe!(b::btBlob, frame::AbstractString)
    _ondemand_loaddat!(b.batch, frame) # loaded on batch
    _bb_frame = get!(OrderedDict, b.batch.frames, frame)
    _b_frame = get!(OrderedDict, _bb_frame, b.uuid)
    return _b_frame
end
getframe!(b::btBlob) = getframe!(b, BLOBBATCH_DEFAULT_FRAME_NAME)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
hasframe(b::btBlob, frame::String) = hasframe(b.batch, frame)