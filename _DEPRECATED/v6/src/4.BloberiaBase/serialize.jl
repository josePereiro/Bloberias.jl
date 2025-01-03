## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# TODO: Generilize callbacks (see ObaServers.jl)
BLOBERIA_ONSERIELIZE_CALLBACKS = Function[]
function onserialize!(B::Bloberia, args...)
    
    # default up meta
    meta = getmeta(B)
    meta["serialization.last.time"] = time()
    
    # custom
    for callback in BLOBERIA_ONSERIELIZE_CALLBACKS
        callback(B)
    end

    return nothing
end

# --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
function serialize_meta!(B::Bloberia)
    path = frame_path(B, "meta")
    fr = _depot_frame(B, "meta")
    _serialize_frame(path, fr)
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
function serialize!(B::Bloberia; lk = false)

    # callback
    onserialize!(B)

    # meta
    __dolock(B, lk; force = false) do
        serialize_meta!(B)
    end
    
    return B
end
