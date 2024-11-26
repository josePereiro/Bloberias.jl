## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# getframe
# load on demand each frame
function getframe(b::vBlob, frame::AbstractString)
    ondemand_loadvframe!(b.batch, frame) # loaded on batch
    return b.batch.vframes[frame][b.uuid]
end

function getframe!(b::vBlob, frame::AbstractString)
    ondemand_loadvframe!(b.batch, frame) # loaded on batch
    _bb_frame = get!(OrderedDict, b.batch.vframes, frame)
    _b_frame = get!(OrderedDict, _bb_frame, b.uuid)
    return _b_frame
end

# ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# hasframe_ram(b::vBlob, frame::AbstractString) = hasframe_ram(b.batch, frame)
# hasframe_disk(b::vBlob, frame::AbstractString) = hasframe_disk(b.batch, frame)
# hasframe(b::vBlob, frame::AbstractString) = hasframe(b.batch, frame)

