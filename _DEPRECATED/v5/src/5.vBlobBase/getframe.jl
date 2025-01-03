## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# getframe
# load on demand each frame
function getframe(b::vBlob, frame::AbstractString)
    ondemand_loadvframe!(b.bb, frame) # loaded on batch
    return b.bb.vframes[frame][b.uuid]
end

function getframe!(b::vBlob, frame::AbstractString)
    ondemand_loadvframe!(b.bb, frame) # loaded on batch
    _bb_frame = get!(OrderedDict, b.bb.vframes, frame)
    _b_frame = get!(OrderedDict, _bb_frame, b.uuid)
    return _b_frame
end

function getframes(vb::vBlob) 
    bb_vframes = getvframes(vb.bb)
    b_frames = VB_VFRAMES_TYPE()
    for (frame, dat) in bb_vframes
        haskey(bb_vframes, vb.uuid) || continue
        b_frames[frame] = dat
    end
    return b_frames
end

# ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# hasvframe_ram(b::vBlob, frame::AbstractString) = hasvframe_ram(b.bb, frame)
# hasvframe_disk(b::vBlob, frame::AbstractString) = hasdframe(b.bb, frame)
# hasvframe(b::vBlob, frame::AbstractString) = hasvframe(b.bb, frame)

