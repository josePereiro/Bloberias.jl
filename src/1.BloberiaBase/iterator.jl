## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
function _eachbatchfile_ch(B::Bloberia, ch_size, sortfun)
    return Channel{String}(ch_size) do _ch
        bb_root = blobbatches_dir(B)
        isdir(bb_root) || return
        paths = sortfun(readdir(bb_root; join = true))
        for path in paths
            _isbatchdir(path) || continue
            put!(_ch, path)
        end
    end
end

function _bb_from_path(B::Bloberia, path, group_pt, preload)
    _isbatchdir(path) || return nothing
    group, uuid_str = _split_batchname(path)
    uuid = parse(UInt128, uuid_str)
    # filter
    _ismatch(group_pt, group) || return nothing
    bb = BlobBatch(B, group, uuid)
    for frame in preload
        _ondemand_loaddat!(bb, frame)
    end
    return bb
end

# returns a channel which iterates for all batches 
# you can filter them
# you can control the order
function _eachbatch_th(B::Bloberia, group_pt = nothing; 
        sortfun = identity, 
        ch_size::Int = 1,
        n_tasks::Int = nthreads(),
        preload = []
    )
    @assert ch_size > 0
    
    return Channel{BlobBatch}(ch_size) do _ch
        file_ch = _eachbatchfile_ch(B, n_tasks, sortfun)
        @sync for _ in 1:n_tasks
            @spawn for path in file_ch
                bb = _bb_from_path(B, path, group_pt, preload)
                isnothing(bb) && continue
                put!(_ch, bb)
            end
        end 
    end # Channel
end

function _eachbatch_ser(B::Bloberia, group_pt = nothing; 
        sortfun = identity, 
        ch_size::Int = 1,
        preload = []
    )
    @assert ch_size > 0
    
    # channel
    return Channel{BlobBatch}(ch_size) do _ch
        file_ch = _eachbatchfile_ch(B, 1, sortfun)
        for path in file_ch
            bb = _bb_from_path(B, path, group_pt, preload)
            isnothing(bb) && continue
            put!(_ch, bb)
        end
    end
end

function eachbatch(B::Bloberia, group_pt = nothing; 
        sortfun = identity, 
        ch_size::Int = 1,
        n_tasks::Int = nthreads(),
        preload = []
    )
    if n_tasks > 1
        return _eachbatch_th(B::Bloberia, group_pt; sortfun, ch_size, n_tasks, preload)
    else
        return _eachbatch_ser(B::Bloberia, group_pt; sortfun, ch_size, preload)
    end
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# foreach_batch
# TODO: make all this multithreading and race safe

function _foreach_batch_ser(f::Function, B::Bloberia, group_pt = nothing; 
        sortfun = identity, 
        ch_size::Int = 1, 
        preload = [], 
        locked = false
    )
    bbs = _eachbatch_ser(B, group_pt; sortfun, ch_size, preload)
    for bb in bbs
        if locked
            try; lock(bb)
                ret = f(bb)
                ret === :break && close(bbs)
                finally; unlock(bb)
            end
        else
            ret = f(bb)
            ret === :break && close(bbs)
        end
    end
    return nothing
end

# .-- .- -.-.-.--. ...---. . . . -- .--. -. -. -.
function _foreach_batch_th(f::Function, B::Bloberia, group_pt = nothing; 
        sortfun = identity, 
        ch_size::Int = 1, 
        n_tasks::Int = nthreads(), 
        preload = [], 
        locked = false
    )

    # channel
    ch = _eachbatch_ser(B, group_pt; sortfun, ch_size, preload)

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

function foreach_batch(f::Function, B::Bloberia, group_pt = nothing; 
        sortfun = identity, 
        ch_size::Int = nthreads(), 
        n_tasks::Int = nthreads(), 
        preload = [], 
        locked = false
    )
    if n_tasks > 1
        _foreach_batch_th(f, B, group_pt; sortfun, ch_size, n_tasks, locked)
    else
        _foreach_batch_ser(f, B, group_pt; sortfun, ch_size, preload, locked)
    end
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

