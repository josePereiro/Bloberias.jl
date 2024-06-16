## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# TODO: make an interface for this so more routines can be added
function onserialize(bb::BlobBatch)
    _ondemand_loadmeta!(bb)
    meta = bb.meta
    if !isempty(bb.uuids)
        meta["blobs.count"] = length(bb.uuids)
    end
    meta["serialization.time"] = time()
    return nothing
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
import Serialization.serialize
function Serialization.serialize(bb::BlobBatch; ignoreempty = true)
    
    ignore = ignoreempty && isempty(bb)
    ignore && return bb
    
    onserialize(bb)

    dir = batchpath(bb)
    isempty(dir) && return # noop
    mkpath(dir)
    
    # meta
    ignore = ignoreempty && isempty(bb.meta)
    if !ignore
        path = meta_framepath(bb)
        _serialize(path, bb.meta)
    end
    
    # uuids
    ignore = ignoreempty && isempty(bb.uuids)
    if !ignore
        path = uuids_framepath(bb)
        _serialize(path, bb.uuids)
    end

    # frames
    ignore = ignoreempty && isempty(bb.frames)
    if !ignore
        for (frame, dat) in bb.frames
            ignoreempty && isempty(dat) && continue
            path = dat_framepath(bb, frame)
            _serialize(path, dat)
        end
    end

    return bb
end

function _inline_newbatch!(bb::BlobBatch)
    bb.uuid = uuid_str()
    bb.meta = OrderedDict()
    bb.uuids = OrderedSet{Int128}()
    bb.frames = OrderedDict()
    bb.temp = OrderedDict()
    nothing
end

function rollserialize!(bb::BlobBatch, lim = BLOBBATCHES_DEFAULT_SIZE_LIM)
    count = blobcount(bb)
    count < lim && return false
    serialize(bb)
    _inline_newbatch!(bb)
    return true
end