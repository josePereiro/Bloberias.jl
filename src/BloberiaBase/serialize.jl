## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# TODO: make an interface for this so more routines can be added
function onserialize!(B::Bloberia, args...)
    _ondemand_loadmeta!(B)
    B.meta["serialization.time"] = time()
    return nothing
end

# --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
function _serialize_meta(B::Bloberia)
    path = meta_framepath(B)
    _serialize(path, B.meta)
end

function _serialize_rablob(B::Bloberia)
    path = rablob_framepath(B, B.rablob_id)
    _mkpath(path)
    _serialize(path, B.rablob)
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
import Serialization.serialize
function Serialization.serialize(B::Bloberia; ignoreempty = true)

    dir = B.root
    isempty(dir) && return # noop
    mkpath(dir)

    # callback
    onserialize!(B)

    # meta
    ignore = ignoreempty && isempty(B.meta)
    ignore || _serialize_meta(B)
    
    # rablobs
    ignore = ignoreempty && isempty(B.rablob)
    ignore || _serialize_rablob(B)

    return B
end

