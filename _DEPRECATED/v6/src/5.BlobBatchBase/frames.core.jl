## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# frame interface

# default id for a frame
dflt_frameid(::BlobBatch) = "bb0"

# Frames must be in a given folder
frames_root(bb::BlobBatch) = bb.root

# the ram object containing the frames
frames_depot(bb::BlobBatch) = bb.frames

# add frame into 'ab' frame depot
# - it should no copy nor modify the 'frame'
function _depot_frame!(bb::BlobBatch, frame::BlobyFrame)
    setindex!(bb.frames, frame, frame.id)
    return nothing
end

# get frame from depot
function _depot_frame(bb::BlobBatch, id::String) 
    return getindex(bb.frames, id)
end

_frame_dat(bb::BlobBatch, bfr::BlobyFrame) = _frame_dat(bfr)

# remove frame from depot, returns the frame
function _undepot_frame!(bb::BlobBatch, id::String) 
    delete!(bb.frames, id)
end

# return true if frame exist
function hasframe_depot(bb::BlobBatch, id::String)
    haskey(bb.frames, id)
end
