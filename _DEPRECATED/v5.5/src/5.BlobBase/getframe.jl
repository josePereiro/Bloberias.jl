## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Get frame only work on blobs local data
# to get a bbfram call it from bb

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# getframe
# load on demand each frame
function getframe(b::Blob, frame::AbstractString)
    ondemand_loadbframe!(b.bb, frame) # loaded on batch
    return b.bb.bframes[frame][b.uuid]
end

function getframe!(b::Blob, frame::AbstractString)
    ondemand_loadbframe!(b.bb, frame) # loaded on batch
    _bb_frame = get!(OrderedDict, b.bb.bframes, frame)
    _b_frame = get!(OrderedDict, _bb_frame, b.uuid)
    return _b_frame
end

function getframes(vb::Blob) 
    bb_bframes = getbframes(vb.bb)
    b_frames = BLOB_BFRAMES_TYPE()
    for (frame, dat) in bb_bframes
        haskey(bb_bframes, vb.uuid) || continue
        b_frames[frame] = dat
    end
    return b_frames
end

# ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# # hasframe
# function hasframe_ram(db::dBlob, frame)
#     # check ram
#     frame == "temp" && return true
#     frame == "meta" && return true
#     haskey(db.frames, frame) && return true
#     return false
# end

# function hasframe_disk(db::dBlob, frame)
#     frame == "temp" && return false
#     frame == "meta" && isfile(meta_jlspath(db))
#     isfile(bframe_jlspath(db, frame)) && return true
#     return false
# end

# function hasframe(db::dBlob, frame)
#     hasframe_ram(db, frame) && return true
#     hasframe_disk(db, frame) && return true
#     return false
# end

# ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# hasbframe_ram(b::Blob, frame::AbstractString) = hasbframe_ram(b.bb, frame)
# hasbframe_disk(b::Blob, frame::AbstractString) = hasbbframe(b.bb, frame)
# hasbframe(b::Blob, frame::AbstractString) = hasbframe(b.bb, frame)

