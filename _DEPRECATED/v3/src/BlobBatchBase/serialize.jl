## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
import Serialization.serialize
function Serialization.serialize(bb::BlobBatch)
    
    up_metadata!(bb)

    dir = batchpath(bb)
    isempty(dir) && return # nopo
    mkpath(dir)
    
    # meta
    if !isempty(bb.meta)
        path = meta_framepath(bb)
        serialize(path, bb.meta)
    end
    
    # uuids
    if !isempty(bb.uuids)
        path = uuids_framepath(bb)
        serialize(path, bb.uuids)
    end

    # lite
    if !isempty(bb.lite)
        path = lite_framepath(bb)
        serialize(path, bb.lite)
    end

    # nonlite
    if !isempty(bb.nonlite)
        for (gkey, gdat) in bb.nonlite
            isempty(gdat) && continue
            path = nonlite_framepath(bb, gkey)
            serialize(path, gdat)
        end
    end

    return bb
end

function _inline_newbatch!(bb::BlobBatch)
    bb.uuid = uuid_str()
    bb.meta = OrderedDict()
    bb.uuids = Int128[]
    bb.lite = OrderedDict()
    bb.nonlite = OrderedDict()
    bb.temp = OrderedDict()
    nothing
end

function rollserialize!(bb::BlobBatch)
    _ondemand_loadmeta!(bb)
    lim = get!(bb.meta, "blobs.lim", 1000)
    _ondemand_loaduuids!(bb)
    count = length(bb.uuids)
    count < lim && return bb
    @show count
    serialize(bb)
    _inline_newbatch!(bb)
    return bb
end