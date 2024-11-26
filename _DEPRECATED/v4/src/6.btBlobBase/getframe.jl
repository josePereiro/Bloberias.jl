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
hasframe_ram(b::btBlob, frame::AbstractString) = hasframe_ram(b.batch, frame)
hasframe_disk(b::btBlob, frame::AbstractString) = hasframe_disk(b.batch, frame)
hasframe(b::btBlob, frame::AbstractString) = hasframe(b.batch, frame)

