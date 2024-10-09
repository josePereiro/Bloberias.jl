## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# returns a channel which iterates for all batches 
# you can filter them
# you can control the order
function eachbatch(B::Bloberia, group_pt = nothing; 
        sortfun = identity, 
        ch_size::Int = 1,
        n_tasks::Int = nthreads(),
        preload = []
    )
    @assert ch_size > 0
    
    # channel
    file_ch = Channel{String}() do _ch
        paths = sortfun(readdir(B.root; join = true))
        for path in paths
            _isbatchdir(path) || continue
            put!(_ch, path)
        end
    end

    return Channel{BlobBatch}(ch_size) do _ch
        @sync for _ in 1:n_tasks
            @spawn for path in file_ch
                group, uuid_str = _split_batchname(path)
                uuid = parse(UInt128, uuid_str)
                # filter
                _ismatch(group_pt, group) || continue
                bb = BlobBatch(B, group, uuid)
                # preload frames
                for frame in preload
                    _ondemand_loaddat!(bb, frame)
                end
                put!(_ch, bb)
            end
        end 
    end
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# foreach_batch
# TODO: make all this multithreading and race safe
function foreach_batch(f::Function, B::Bloberia, group_pt = nothing; 
        sortfun = identity, 
        ch_size::Int = nthreads(), 
        preload = [], 
        locked = false
    )
    bbs = eachbatch(B, group_pt; sortfun, ch_size, preload)
    for bb in bbs
        if locked
            try; lock(bb)
                ret = f(bb)
                ret === :break && close(bb)
                finally; unlock(bb)
            end
        else
            ret = f(bb)
            ret === :break && close(bbs)
        end
    end
    return nothing
end

## .-- .- -.-.-.--. ...---. . . . -- .--. -. -. -.
function foreach_batch_th(f::Function, B::Bloberia, group_pt = nothing; 
        sortfun = identity, 
        n_tasks::Int = nthreads(), 
        locked = false
    )

    # channel
    ch = Channel{BlobBatch}() do _ch
        paths = sortfun(readdir(B.root; join = true))
        for path in paths
            _isbatchdir(path) || continue
            # group filter
            group, uuid_str = _split_batchname(path)
            uuid = parse(UInt128, uuid_str)
            _ismatch(group_pt, group) || continue
            bb = BlobBatch(B, group, uuid)
            put!(_ch, bb)
        end
    end

    # spawn
    @sync for _ in 1:n_tasks
        if locked
            # ------------
            @spawn begin
                for bb in ch
                    try; lock(bb)
                        ret = f(bb)
                        ret === :break && close(ch)
                    finally; unlock(bb)
                    end
                end # for bb
            end # @spawn
        else
            # ------------
            @spawn begin
                for bb in ch
                    ret = f(bb)
                    ret === :break && close(ch)
                end # for bb
            end # @spawn
        end
    end # for t
    return nothing
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Iterator
function _B_iterate_next(ch, ch_next)
    isnothing(ch_next) && return nothing
    item, ch_state = ch_next
    B_state = (ch, ch_state)
    return (item, B_state)
end

import Base.iterate
function Base.iterate(B::Bloberia)
    ch = eachbatch(B)
    ch_next = iterate(ch)
    return _B_iterate_next(ch, ch_next)
end

function Base.iterate(::Bloberia, B_state) 
    isnothing(B_state) && return nothing
    ch, ch_state = B_state
    ch_next = iterate(ch, ch_state)
    return _B_iterate_next(ch, ch_next)
end

