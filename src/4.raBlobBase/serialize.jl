## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# TODO: make an interface for this so more routines can be added
function onserialize!(rb::raBlob, args...)
    meta = getframe(rb, "meta")
    meta["serialization.time"] = time()
    return nothing
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
function _serialize_meta(rb::raBlob)
    path = meta_framepath(rb)
    _serialize(path, rb.meta)
end

function _serialize_datframe(rb::raBlob, frame)
    path = dat_framepath(rb, frame)
    _serialize(path, rb.frames[frame])
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
import Serialization.serialize
function Serialization.serialize(rb::raBlob; ignoreempty = false)
    
    onserialize!(rb)

    dir = rablobpath(rb)
    mkpath(dir)
    
    # meta
    ignore = ignoreempty && isempty(rb.meta)
    ignore || _serialize_meta(rb)

    # frames
    ignore = ignoreempty && isempty(rb.frames)
    if !ignore
        for (frame, dat) in rb.frames
            ignoreempty && isempty(dat) && continue
            _serialize_datframe(rb, frame)
        end
    end

    return rb
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
import Serialization.serialize
function Serialization.serialize(rb::raBlob, frame::AbstractString; ignoreempty = true)
    
    onserialize!(rb, frame)
    dir = rablobpath(rb)
    mkpath(dir)
    
    # meta
    if frame == "meta"
        ignore = isempty(rb.meta)
        ignore = ignore && ignoreempty 
        ignore || _serialize_meta(rb)
        return
    end
    
    # uuids
    if frame == "uuids"
        ignore = isempty(rb.uuids)
        ignore = ignore && ignoreempty 
        ignore || _serialize_uuids(rb)
    end

    # frames
    ignore = isempty(rb.frames) | isempty(rb.frames[frame])
    ignore = ignore && ignoreempty 
    ignore || _serialize_datframe(rb, frame)

    return rb
end

