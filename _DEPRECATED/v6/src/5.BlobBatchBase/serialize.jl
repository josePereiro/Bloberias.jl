## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# TODO: Generilize callbacks (see ObaServers.jl)
BLOBBATCH_ONSERIELIZE_CALLBACKS = Function[]
function onserialize!(bb::BlobBatch, args...)
    
    # default up meta
    meta = getmeta(bb)
    meta["serialization.last.time"] = time()
    meta["blobs.cached.count"] = blobcount(bb)
    
    # custom
    for callback in BLOBBATCH_ONSERIELIZE_CALLBACKS
        callback(bb)
    end

    return nothing
end

# --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
function serialize_meta!(bb::BlobBatch)
    path = frame_path(bb, META_FRAMEID)
    _serialize_frame(path, _depot_frame(bb, META_FRAMEID))
end

function serialize_buuids!(bb::BlobBatch)
    path = frame_path(bb, bUUIDS_FRAMEID)
    _serialize_frame(path, _depot_frame(bb, bUUIDS_FRAMEID))
end

serialize_bbframes!(bb::BlobBatch) = 
    serialize_frames!(bb) do fr
        _frame_fT(fr) == bb_bbFRAME_FRAME_TYPE
    end
serialize_bframes!(bb::BlobBatch) = 
    serialize_frames!(bb) do fr
        _frame_fT(fr) == bb_bFRAME_FRAME_TYPE
    end


## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
function _serialize!(bb::BlobBatch, id)

    # callback
    onserialize!(bb)

    serialize_meta!(bb)
    id == "meta" && return # only meta

    # frames
    serialize_frames!(bb) do fr
        isnothing(id) && return true # serialize all
        isempty(id) && return true   # serialize all
        # fr.id == id || return false  # serialize just id
        # if bframe, always serialize buuids (for sync)
        # _frame_fT(fr) == bb_bFRAME_FRAME_TYPE || return true
        # serialize_buuids!(bb) # serialize
        return true
    end

    return bb
end
function serialize!(bb::BlobBatch, id = nothing; lk = false)
    __dolock(bb, lk) do
        _serialize!(bb, id)
    end
end