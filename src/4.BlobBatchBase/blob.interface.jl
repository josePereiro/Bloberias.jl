## --.-.--..-- - -- - - - -- . . . .. -. - - -- - 
# interface

_depot_rootdir_I(bb::BlobBatch) = bb.root

# return the frames depot
_frames_depot_I(bb::BlobBatch) = bb.frames

# most return (container, key)
function _depotpath_I(bb::BlobBatch, frameid::String) 
    return (bb.frames, frameid)
end

function _frame_filepath_I(bb::BlobBatch, frameid::String)
    return get!(bb.temp, frameid) do
        _frame_filepath(_depot_rootdir_I(bb), frameid)
    end
end

# create the full path in the depot
function _mk_depotpath_I!(bb::BlobBatch, frameid::String) 
    get!(bb.frames, frameid) do
        Dict{Union{UInt128, String}, Any}()
    end
    return nothing
end

# check for blob path
function _has_depotpath_I(bb::BlobBatch, frameid::String) 
    return haskey(bb.frames, frameid) 
end

# use for trigger load 
function _frame_demand_load_I(bb::BlobBatch, frameid::String)
    haskey(bb.frames, frameid) && return false
    # isempty(getindex(bb.frames, frameid)) && return false
    return true
end