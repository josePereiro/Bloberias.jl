## --.-.--..-- - -- - - - -- . . . .. -. - - -- - 
# File sys

_frame_filepath(root::String, frameid::String) = 
            joinpath(root, string(frameid, ".frame.jls"))

## --.-.--..-- - -- - - - -- . . . .. -. - - -- - 
# hasframe

function _hasframe_disk(ab::AbstractBlob, frameid::String) 
    path = _frame_filepath_I(ab, frameid)
    return isfile(path)
end


## --.-.--..-- - -- - - - -- . . . .. -. - - -- - 
# serialization

function _serialize_frame(ab::AbstractBlob, frameid::String, dat::Dict)
    path = _frame_filepath_I(ab, frameid)
    _serialize_frame(path, dat)
end

function _deserialize_frame(ab::AbstractBlob, frameid::String)
    path = _frame_filepath_I(ab, frameid)
    return _deserialize_frame(path)
end