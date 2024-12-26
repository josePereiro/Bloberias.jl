## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 

# default id for a frame
dflt_frameid(::Blob) = "b0"

# Frames must be in an unique folder for each blob
frames_root(b::Blob) = frames_root(b.bb)

# the ram object containing the frames/dat
# - It should be the actual object
# - blob are distributed acroos several frames
frames_depot(b::Blob) = frames_depot(b.bb)

function _frame_dat(b::Blob, fr::BlobyFrame)
    fr = _frame_dat(b.bb, fr)
    return fr[b.uuid]
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# add frame into 'ab' frame depot
function _depot_frame!(b::Blob, frame::BlobyFrame) 
    fr = _depot_frame!(b.bb, frame)
    # _assert_fT(fr, bb_bFRAME_FRAME_TYPE)
    return fr
end

# get frame from depot
function _depot_frame(b::Blob, id::String) 
    fr = _depot_frame(b.bb, id)
    # _assert_fT(fr, bb_bFRAME_FRAME_TYPE)
    return fr
end

_undepot_frame!(b::Blob, id::String)=
    _undepot_frame!(b, id)

hasframe_depot(b::Blob, id::String) = hasframe_depot(b.bb, id)