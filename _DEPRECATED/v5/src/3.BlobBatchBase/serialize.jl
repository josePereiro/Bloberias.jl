## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# TODO: make an interface for this so more routines can be added
function onserialize!(bb::BlobBatch, args...)
    meta = getmeta(bb)
    meta["serialization.last.time"] = time()
    return nothing
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
function _serialize_bb!(f::Function, bb::BlobBatch; check_overflow = true)
    # Is closed
    # TODO: jaja, if it is closed I can not serialized
    # but how can I store that I close it
    isopen(bb) ||
        error("The batch is closed, see 'open!', 'close!'")

    # Is full interface
    check_overflow && isoverflowed(bb) && 
        error("The batch is overflowed, check 'vblobcount' and 'vbloblim'")
    
    onserialize!(bb)
    mkpath(bb)

    f(bb)

    return nothing
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
function _serialize_vuuids!(bb::BlobBatch; ignoreempty = true, _...)
    ignoreempty && isempty(bb.vuuids) && return
    path = vuuids_jlspath(bb)
    _serialize(path, bb.vuuids)
end
serialize_vuuids!(bb::BlobBatch; kwrags...) = 
    _serialize_bb!(bb; check_overflow = true) do bb
        _serialize_meta!(bb; kwrags...)
        _serialize_vuuids!(bb; kwrags...)
    end

function _serialize_meta!(bb::BlobBatch; ignoreempty = true, _...)
    ignoreempty && isempty(bb.vuuids) && return
    path = meta_jlspath(bb)
    _serialize(path, bb.meta)
end
serialize_meta!(bb::BlobBatch; kwargs...) = 
    _serialize_bb!(bb; check_overflow = false) do bb
        _serialize_meta!(bb; kwargs...)
    end

function _serialize_frames!(bb::BlobBatch, frames, pathfun; 
        frame = nothing,
        ignoreempty = false,
    )
    if isnothing(frame)
        for (_frame, dat) in frames
            ignoreempty && isempty(dat) && continue
            path = pathfun(bb, _frame)
            _serialize(path, dat)
        end
    else
        dat = frames[frame]
        ignoreempty && isempty(dat) && return
        path = pathfun(bb, frame)
        _serialize(path, dat)
    end
    return nothing
end

_serialize_vframe!(bb::BlobBatch; kwargs...) =
    _serialize_frames!(bb, bb.vframes, vframe_jlspath; kwargs...)
serialize_vframe!(bb::BlobBatch, frame = nothing; kwargs...) = 
    _serialize_bb!(bb; check_overflow = true) do bb
        _serialize_meta!(bb)
        _serialize_vuuids!(bb)
        _serialize_vframe!(bb; frame, kwargs...)
    end

_serialize_dframe!(bb::BlobBatch; kwargs...) = 
    _serialize_frames!(bb, bb.dframes, dframe_jlspath; kwargs...)
serialize_dframe!(bb::BlobBatch, frame = nothing; kwargs...) = 
    _serialize_bb!(bb; check_overflow = false) do bb
        _serialize_meta!(bb)
        _serialize_dframe!(bb; frame, kwargs...)
    end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# serialize all or a particular frame depending on 'frame'
function serialize!(bb::BlobBatch; 
        frame = nothing, # targeted frame
        ignoreempty = false, 
        include_dframes = true,
        include_vframes = true,
    )
    check_overflow = include_vframes
    _serialize_bb!(bb; check_overflow) do bb

        # meta (always serialize)
        _serialize_meta!(bb; ignoreempty)

        # dframes
        include_dframes && _serialize_dframe!(bb; frame, ignoreempty)
        
        # vframes
        include_dframes && _serialize_vuuids!(bb; frame, ignoreempty)
        include_dframes && _serialize_vframe!(bb; frame, ignoreempty)

        return nothing
    end
end
