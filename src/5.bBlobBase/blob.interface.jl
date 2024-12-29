## --.-.--..-- - -- - - - -- . . . .. -. - - -- - 
# interface

_depot_rootdir_I(b::iBlob) = _depot_rootdir_I(b.bb)

# return the frames depot
_frames_depot_I(b::iBlob) = _frames_depot_I(b.bb)

# most return (container, key)
function _depotpath_I(b::iBlob, frameid::String) 
    _bb_frame = _getindex_depot_frame(b.bb, frameid)
    return (_bb_frame, b.uuid)
end

function _frame_filepath_I(b::iBlob, frameid::String)
    return _frame_filepath_I(b.bb, frameid)
end

# create the full path in the depot
function _mk_depotpath_I!(b::iBlob, frameid::String) 
    _mk_depotpath_I!(b.bb, frameid)
    _bb_frame = _getindex_depot_frame(b.bb, frameid)
    get!(_bb_frame, b.uuid) do
        Dict{String, Any}()
    end
    return nothing
end

# check for blob path
function _has_depotpath_I(b::iBlob, frameid::String)
    _has_depotpath_I(b.bb, frameid) || return false
    _bb_frame = _getindex_depot_frame(b.bb, frameid)
    haskey(_bb_frame, b.uuid) || return false
    return true
end

# use for trigger load 
function _frame_demand_load_I(b::iBlob, frameid::String)
    return _frame_demand_load_I(b.bb, frameid)
end