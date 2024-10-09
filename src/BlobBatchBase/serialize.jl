## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# TODO: make an interface for this so more routines can be added
function onserialize!(bb::BlobBatch, args...)
    meta = getframe(bb, "meta")
    meta["serialization.time"] = time()
    return nothing
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
function _serialize_uuids(bb)
    path = uuids_framepath(bb)
    _serialize(path, bb.uuids)
end

function _serialize_meta(bb)
    path = meta_framepath(bb)
    _serialize(path, bb.meta)
end


function _serialize_datframe(bb, frame)
    path = dat_framepath(bb, frame)
    _serialize(path, bb.frames[frame])
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
import Serialization.serialize
function Serialization.serialize(bb::BlobBatch; ignoreempty = true)
    
    ignore = ignoreempty && isempty(bb)
    ignore && return bb
    
    onserialize!(bb)

    dir = batchpath(bb)
    isempty(dir) && return # noop
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
    
    ignore = isempty(bb)
    ignore = ignore && ignoreempty 
    ignore && return bb
    
    onserialize!(bb, frame)

    dir = batchpath(bb)
    isempty(dir) && return # noop
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

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
function _inline_newbatch!(bb::BlobBatch)
    bb.uuid = uuid_int()
    bb.meta = OrderedDict()
    bb.uuids = OrderedSet{Int128}()
    bb.frames = OrderedDict()
    bb.temp = OrderedDict()
    nothing
end

# TODO: sync with "meta" limit config
# function rollserialize!(bb::BlobBatch, lim = BLOBBATCHES_DEFAULT_SIZE_LIM)
#     count = blobcount(bb)
#     count < lim && return false
#     serialize(bb)
#     _inline_newbatch!(bb)
#     return true
# end