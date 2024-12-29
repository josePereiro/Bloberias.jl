## --.-.--..-- - -- - - - -- . . . .. -. - - -- - 
# interface

_depot_rootdir_I(B::Bloberia) = B.root

# return the frames depot
_frames_depot_I(B::Bloberia) = B.frames

function _frame_filepath_I(B::Bloberia, frameid::String)
    return get!(B.temp, frameid) do
        _frame_filepath(_depot_rootdir_I(B), frameid)
    end
end

# most return (container, key)
function _depotpath_I(B::Bloberia, frameid::String) 
    return (B.frames, frameid)
end

# create the full path in the depot
function _mk_depotpath_I!(B::Bloberia, frameid::String) 
    get!(B.frames, frameid) do
        Dict{String, Any}()
    end
    return nothing
end

# check for blob path
function _has_depotpath_I(B::Bloberia, frameid::String) 
    return haskey(B.frames, frameid) 
end

# use for trigger load 
function _frame_demand_load_I(B::Bloberia, frameid::String)
    haskey(B.frames, frameid) && return false
    # isempty(getindex(B.frames, frameid)) && return false
    return true
end