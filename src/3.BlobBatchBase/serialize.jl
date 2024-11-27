## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# TODO: make an interface for this so more routines can be added
function onserialize!(bb::BlobBatch, args...)
    meta = getmeta(bb)
    meta["serialization.last.time"] = time()
    return nothing
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
function serialize_vuuids!(bb::BlobBatch)
    path = vuuids_jlspath(bb)
    _serialize(path, bb.vuuids)
end

function serialize_meta!(bb::BlobBatch)
    path = meta_jlspath(bb)
    _serialize(path, bb.meta)
end

function serialize_vframe!(bb::BlobBatch, frame)
    path = vframe_jlspath(bb, frame)
    _serialize(path, bb.vframes[frame])
end

function serialize_dframe!(bb::BlobBatch, frame)
    path = dframe_jlspath(bb, frame)
    _serialize(path, bb.dframes[frame])
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# serialize all or a particular frame depending on 'id'
function serialize!(bb::BlobBatch, id = nothing; ignoreempty = false)
    
    # TODO: Go back to isfull interface better
    # TODO: This might be to restrictive (Think about it)
    # - Maybe close individual files
    # isopen(bb) || error("This batch is closed!!!")
    
    onserialize!(bb)
    mkpath(bb)
    
    # meta
    if isnothing(id) || id == "meta"
        ignore = ignoreempty && isempty(bb.meta)
        ignore || serialize_meta!(bb)
    end
    
    # uuids
    if isnothing(id) || id == "vuuids"
        ignore = ignoreempty && isempty(bb.vuuids)
        ignore || serialize_vuuids!(bb)
    end

    # frames
    for (frames, serfun) in [
            (bb.vframes, serialize_vframe!), 
            (bb.dframes, serialize_dframe!), 
        ]
        ignore = ignoreempty && isempty(frames)
        ignore && continue
        for (framekey, dat) in frames
            if isnothing(id) || id == framekey
                ignoreempty && isempty(dat) && continue
                serfun(bb, framekey)
            end
        end
    end

    return bb
end
