## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# TODO: make an interface for this so more routines can be added
function onserialize!(bb::BlobBatch, args...)
    meta = getframe(bb, "meta")
    meta["serialization.time"] = time()
    return nothing
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
function _serialize_uuids(bb::BlobBatch)
    path = uuids_framepath(bb)
    _serialize(path, bb.uuids)
end

function _serialize_meta(bb::BlobBatch)
    path = meta_framepath(bb)
    _serialize(path, bb.meta)
end


function _serialize_datframe(bb::BlobBatch, frame)
    path = dat_framepath(bb, frame)
    _serialize(path, bb.frames[frame])
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
import Serialization.serialize
function Serialization.serialize(bb::BlobBatch; ignoreempty = false)
    
    onserialize!(bb)

    dir = batchpath(bb)
    mkpath(dir)
    
    # meta
    ignore = ignoreempty && isempty(bb.meta)
    ignore || _serialize_meta(bb)
    
    # uuids
    ignore = ignoreempty && isempty(bb.uuids)
    ignore || _serialize_uuids(bb)

    # frames
    ignore = ignoreempty && isempty(bb.frames)
    if !ignore
        for (frame, dat) in bb.frames
            ignoreempty && isempty(dat) && continue
            _serialize_datframe(bb, frame)
        end
    end

    return bb
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
import Serialization.serialize
function Serialization.serialize(bb::BlobBatch, frame::AbstractString; ignoreempty = true)
    
    onserialize!(bb, frame)

    dir = batchpath(bb)
    mkpath(dir)
    
    # meta
    if frame == "meta"
        ignore = isempty(bb.meta)
        ignore = ignore && ignoreempty 
        ignore || _serialize_meta(bb)
        return
    end
    
    # uuids
    if frame == "uuids"
        ignore = isempty(bb.uuids)
        ignore = ignore && ignoreempty 
        ignore || _serialize_uuids(bb)
    end

    # frames
    ignore = isempty(bb.frames) | isempty(bb.frames[frame])
    ignore = ignore && ignoreempty 
    ignore || _serialize_datframe(bb, frame)

    return bb
end