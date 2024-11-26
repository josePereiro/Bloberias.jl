# TODO: serialize meta

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# TODO: make an interface for this so more routines can be added
function onserialize!(B::Bloberia, args...)
    _ondemand_loadmeta!(B)
    B.meta["serialization.last.time"] = time()
    return nothing
end

# --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
function _serialize_meta(B::Bloberia)
    path = meta_framepath(B)
    _serialize(path, B.meta)
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
import Serialization.serialize
function Serialization.serialize(B::Bloberia; ignoreempty = true)

    dir = bloberia_dir(B)
    mkpath(dir)

    # callback
    onserialize!(B)

    # meta
    ignore = ignoreempty && isempty(B.meta)
    ignore || _serialize_meta(B)

    return B
end
