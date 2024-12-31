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
    _ondemand_serialize_depot_frame(bb, "meta")
end

# --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
function serialize_buuids!(bb::BlobBatch)
    _ondemand_serialize_depot_frame(bb, "buuids")
end


## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
function _serialize!(bb::BlobBatch, id0)

    # callback
    onserialize!(bb)

    # frames
    _serialize_frames!(bb) do id
        id == "meta" && return true # always serialize meta
        isnothing(id0) && return true # serialize all
        isempty(id0) && return true   # serialize all
        return id == id0
    end

    return bb
end
function serialize!(bb::BlobBatch, id = nothing; lk = false)
    __dolock(bb, lk) do
        _serialize!(bb, id)
    end
end