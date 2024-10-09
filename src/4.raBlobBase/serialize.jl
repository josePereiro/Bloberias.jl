## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# TODO: make an interface for this so more routines can be added
function onserialize!(rb::raBlob, args...)
    return nothing
end

function _serialize_rablob(rb::raBlob)
    path = rablob_framepath(rb)
    _mkpath(path)
    _serialize(path, rb.data)
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
import Serialization.serialize
function Serialization.serialize(rb::raBlob; ignoreempty = true)

    dir = rb.B.root
    isempty(dir) && return # noop
    mkpath(dir)

    # callback
    onserialize!(rb)

    # rablob
    ignore = ignoreempty && isempty(rb.data)
    ignore || _serialize_rablob(rb)

    return rb
end

