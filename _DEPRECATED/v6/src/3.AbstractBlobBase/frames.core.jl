## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# DONE
# - options most functions needs to support
#   - assert fT
#   - get default if frame is missing
#       - maybe more general if method fail (TAI)
# - All io operations 
#   - free frame <-> depot frame
#   - disk frame <-> depot frame
#   - free frame <-> disk frame
#   - missing <-> disk 
#   - missing <-> depot

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# AbstractBlob
# - A blob is an object that allow you to make operations with a frame
# - Bacause a frame is a file, a blob can be seems as a partial path

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# frame interface

# default id for a frame
dflt_frameid(::AbstractBlob) = error("Missing implementation")

# Frames must be in an unique folder for each blob
frames_root(::AbstractBlob) = error("Missing implementation")

# the path to a frame file
frame_path(ab::AbstractBlob, id) = frame_path(frames_root(ab), id)

# the ram object containing the frames
frames_depot(::AbstractBlob) = error("Missing implementation")

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# deserialize and returns a frame using 'ab' as path root
function _deserialize_frame(ab::AbstractBlob, id::String, 
        onerr = _IGNORE
    ) 
    _trycall(onerr) do
        return _deserialize_frame(frame_path(ab, id))
    end
end

# serialize a frame using 'ab' as path root
function _serialize_frame(ab::AbstractBlob, frame::BlobyFrame, id::String, 
        onerr = _IGNORE
    )
    _trycall(onerr) do
        _serialize_frame(frame_path(ab, id), frame)
    end
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# add frame into 'ab' frame depot
_depot_frame!(ab::AbstractBlob, frame::BlobyFrame) = error("Missing implementation")
# query depot or disk, if missing, 
# 'build' most return a new Frame to be deposit on 'ab'
function _depot_frame!(build::Function, ab::AbstractBlob, fT::Symbol, id::String)
    # Check id
    # If exist I return no matter the type 
    # I check separately for avoiding file queries
    if hasframe_depot(ab, id) 
        fr = _depot_frame(ab, id)
        _assert_fT(fr, fT)
        return fr
    end
    if hasframe_disk(ab, id) 
        _load_frame!(ab, fT, id)
        fr = _depot_frame(ab, id)
        return fr
    end
    # if missing
    fr = build()
    _assert_fT(fr, fT)
    _depot_frame!(ab, fr)
    return fr
end


# get frame from depot
_depot_frame(ab::AbstractBlob, id::String) = error("Missing implementation")
function _depot_frame(onmiss, ab::AbstractBlob, id::String)
    flag = hasframe_depot(ab, id)
    return _conditionalcall(flag, onmiss) do
        _depot_frame(ab, id)
    end
end
_depot_frame(ab::AbstractBlob, id::String, onmiss) = 
    _depot_frame(onmiss, ab, id)

# remove frame from depot, returns the frame
_undepot_frame!(ab::AbstractBlob, id::String) = error("Missing implementation")
function _undepot_frame!(ab::AbstractBlob, id::String, onerr)
    _trycall(onerr) do
        _undepot_frame!(ab, id)
    end
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# deposit frame from disk
function _load_frame!(ab::AbstractBlob, fT::Symbol, id::String, 
        onerr = _IGNORE
    )
    _trycall(onerr) do
        frame = _deserialize_frame(ab, id)
        _assert_fT(frame, fT)
        _depot_frame!(ab, frame) 
        return frame
    end
end
load_frame!(ab::AbstractBlob, id::String, onerr = _IGNORE) = 
    _load_frame!(ab, :IGNORE, id, onerr)



# return true if frame exist
hasframe_depot(ab::AbstractBlob, id::String) = error("Missing implementation")
hasframe_depot(ab::AbstractBlob) = hasframe_depot(ab, dflt_frameid(ab))
hasframe_disk(ab::AbstractBlob, id::String) = 
    isfile(frame_path(ab, id))
hasframe_disk(ab::AbstractBlob) = hasframe_disk(ab, dflt_frameid(ab))
hasframe(ab::AbstractBlob, id::String) = 
    hasframe_depot(ab, id) || hasframe_disk(ab, id)
hasframe(ab::AbstractBlob) = hasframe(ab, dflt_frameid(ab))

# load frame if is not in the depot
function _onmissload_frame(ab::AbstractBlob, fT::Symbol, id::String, 
        onerr = _IGNORE
    )
    _trycall(onerr) do
        hasframe_depot(ab, id) && return nothing 
        _load_frame!(ab, fT, id)
        return nothing
    end
end
onmissload_frame(ab::AbstractBlob, id::String, onerr = _IGNORE) =
    _onmissload_frame(ab::AbstractBlob, :IGNORE, id, onerr)

function serialize_depot_frame(ab::AbstractBlob, id::String,
        onerr = _IGNORE
    )
    _trycall(onerr) do
        frame = _depot_frame(ab, id)
        _serialize_frame(ab, frame, id)
    end
end

## ---- . .- ..- -.--.- . .-..--... - -- -. . .....
# get both ram and disk versions and allow you to have a do block
# returns ram frame
function _withframes(dofun::Function, ab::AbstractBlob, id::String)
    ramframe = _depot_frame(ab, id, nothing)
    diskframe = _deserialize_frame(ab, id, nothing)
    if !isnothing(ramframe) && !isnothing(diskframe) 
        _assert_fT(ramframe, _frame_fT(diskframe))
    end
    return dofun(ramframe, diskframe)
end

# merge disk version with ram version
# 'f' allow you to custom merge frames dat
# at the end, the ram data will be serialized back into disk...
function _mergeframes!(f::Function, ab::AbstractBlob, fT::Symbol, id::String, 
        onerr  = _IGNORE
    )
    _trycall(onerr) do
        rfr = _withframes(f, ab, id)
        _assert_fT(rfr, fT)
        _depot_frame!(ab, rfr)
        _serialize_frame(ab, rfr, id)
        return rfr
    end
end
