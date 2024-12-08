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
function _serialize_buuids!(bb::BlobBatch; ignoreempty = true, _...)
    ignoreempty && isempty(bb.buuids) && return
    path = buuids_jlspath(bb)
    _serialize(path, bb.buuids)
end
serialize_buuids!(bb::BlobBatch; kwrags...) = 
    _serialize_bb!(bb; check_overflow = true) do bb
        _serialize_meta!(bb; kwrags...)
        _serialize_buuids!(bb; kwrags...)
    end

function _serialize_meta!(bb::BlobBatch; ignoreempty = true, _...)
    ignoreempty && isempty(bb.buuids) && return
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

_serialize_bframe!(bb::BlobBatch; kwargs...) =
    _serialize_frames!(bb, bb.bframes, bframe_jlspath; kwargs...)
serialize_bframe!(bb::BlobBatch, frame = nothing; kwargs...) = 
    _serialize_bb!(bb; check_overflow = true) do bb
        _serialize_meta!(bb)
        _serialize_buuids!(bb)
        _serialize_bframe!(bb; frame, kwargs...)
    end

_serialize_bbframe!(bb::BlobBatch; kwargs...) = 
    _serialize_frames!(bb, bb.bbframes, bbframe_jlspath; kwargs...)
serialize_bbframe!(bb::BlobBatch, frame = nothing; kwargs...) = 
    _serialize_bb!(bb; check_overflow = false) do bb
        _serialize_meta!(bb)
        _serialize_bbframe!(bb; frame, kwargs...)
    end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# serialize all or a particular frame depending on 'frame'
# TODO: now we have blob frames and batch frames.
function serialize!(bb::BlobBatch; 
        frame = nothing, # targeted frame
        ignoreempty = false, 
        include_bbframes = true,
        include_bframes = true,
    )
    check_overflow = include_bframes
    _serialize_bb!(bb; check_overflow) do bb

        # meta (always serialize)
        _serialize_meta!(bb; ignoreempty)

        # bbframes
        include_bbframes && _serialize_bbframe!(bb; frame, ignoreempty)
        
        # bframes
        include_bbframes && _serialize_buuids!(bb; frame, ignoreempty)
        include_bbframes && _serialize_bframe!(bb; frame, ignoreempty)

        return nothing
    end
end
