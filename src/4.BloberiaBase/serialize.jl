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
    _serialize(path, _getmeta(B))
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
function serialize!(B::Bloberia; lk = true)

    # callback
    onserialize!(B)

    # meta
    __dolock(B, lk) do
        serialize_meta!(B)
    end
    
    return B
end
