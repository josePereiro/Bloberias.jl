## --.--. .- . .- -- - ---- .- - .- .-.- .- -.-. 
function _serialize_frame(path::String, dat::Dict)
    _mkpath(path)
    serialize(path, dat)
end

function _deserialize_frame(fpath::String)
    return deserialize(fpath)
end
