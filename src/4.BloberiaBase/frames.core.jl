## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# frame interface

# default id for a frame
dflt_frameid(::Bloberia) = "meta"

# Frames must be in a given folder
frames_root(B::Bloberia) = B.root

# add frame into 'ab' frame depot
# - it should not copy nor modify the 'frame'
function _depot_frame!(B::Bloberia, frame::BlobyFrame)
    _assert_fT(frame, META_FRAME_TYPE)
    setindex!(B.frames, frame, frame.id)
    return nothing
end

# get frame from depot
function _depot_frame(B::Bloberia, id::String) 
    return getindex(B.frames, id)
end


# remove frame from depot, returns the frame
function _undepot_frame!(B::Bloberia, id::String) 
    delete!(B.frames, id)
end

# return true if frame exist
function hasframe_depot(B::Bloberia, id::String)
    haskey(B.frames, id)
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# frame data interface

# ram container
# - It should be the actual object
frames_depot(B::Bloberia) = B.frames

function getframe!(B::Bloberia, id::String)
    _depot_frame!(B, id) do
        # Check id
        id == META_FRAMEID || error("Bloberia only has a 'meta' frame, got: '$id'")
        return BlobyFrame{META_FRAME_TYPE, DICT_DEPOT_TYPE}(id, DICT_DEPOT_TYPE())
    end
    return getframe(B, id)
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# frames accessors
getmeta(B::Bloberia) = getframe(B, META_FRAMEID)
function getmeta!(B::Bloberia)
    _depot_frame!(B, META_FRAMEID) do
        # if missing
        return BlobyFrame{META_FRAME_TYPE, DICT_DEPOT_TYPE}(META_FRAMEID, DICT_DEPOT_TYPE())
    end
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 

import Base.setindex!
function Base.setindex!(B::Bloberia, val, frameid::String, key::String) 
    fr = getframe!(B, frameid)
    setindex!(fr, val, key)
end

import Base.get
function Base.get(dflt::Function, B::Bloberia, frameid::String, key::String)
    hasframe(B, frameid) || return dflt()
    fr = getframe(B, frameid)
    return get(dflt, fr, key)
end



import Base.get!
function Base.get!(dflt::Function, B::Bloberia, frameid::String, key::String)
    fr = getframe!(B, frameid)
    return get!(dflt, fr, key)
end

import Base.empty!
Base.empty!(B::Bloberia) = empty!(B.frames)
Base.empty!(B::Bloberia, id::String) = empty!(B.frames[id])
import Base.isempty
Base.isempty(B::Bloberia) = isempty(B.frames)
