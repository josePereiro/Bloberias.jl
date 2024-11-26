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
    path = meta_jlspath(B)
    _serialize(path, B.meta)
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
function serialize!(B::Bloberia)
    
    mkpath(B)

    # callback
    onserialize!(B)

    # meta
    serialize_meta!(B)

    return B
end
