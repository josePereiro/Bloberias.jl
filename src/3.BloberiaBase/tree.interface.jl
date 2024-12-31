## --.-.--..-- - -- - - - -- . . . .. -. - - -- - 
# interface

_deflt_frameid_I(::Bloberia) = "meta"

_rootdir_I(B::Bloberia) = B.root

_frames_depotdir_I(B::Bloberia) = B.root

# return the frames depot
_frames_depot_I(B::Bloberia) = B.frames

# most return (container, key)
function _depotpath_I(::Bloberia, frameid::String, depot) 
    return (depot, frameid)
end

# create an empty frame in the depot
function _mk_depotframe_I!(::Bloberia, frameid::String, depot::Dict)
    get!(depot, frameid) do
        Dict{String, Any}()
    end
    return nothing
end

# create the full path in the depot
function _mk_depotpath_I!(B::Bloberia, frameid::String, depot::Dict)
    _mk_depotframe_I!(B, frameid, depot)
    return nothing
end

# check for blob path
function _has_depotpath_I(::Bloberia, frameid::String, depot)
    return haskey(depot, frameid) 
end

# use for trigger load 
function _frame_demand_load_I(B::Bloberia, frameid::String)
    haskey(B.frames, frameid) && return false
    return true
end

# use for trigger serialization
function _frame_demand_serialization_I(B::Bloberia, frameid::String)
    haskey(B.frames, frameid) && return true
    # TODO/ think about serializing empty frames
    # isempty(getindex(B.frames, frameid)) && return false
    return false
end