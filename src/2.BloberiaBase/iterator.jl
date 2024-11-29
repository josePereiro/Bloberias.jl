## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
function _eachbatchfile_ch(B::Bloberia, ch_size, sortfun)
    return Channel{String}(ch_size) do _ch
        root0 = bloberiapath(B)
        isdir(root0) || return
        paths = sortfun(readdir(root0; join = true))
        for path in paths
            _isbatchdir(path) || continue
            put!(_ch, path)
        end
    end
end

# 'preload': frames to preload
_startswith(bbid, bbid_prefix) = startswith(bbid, bbid_prefix) 
_startswith(bbid, bbid_prefix::Nothing) = true

function _bb_from_path(B::Bloberia, path, bbid_prefix, preload)
    _isbatchdir(B, path) || return nothing
    bbid = basename(path)
    # filter
    # _ismatch(bbid_prefix, bbid) || return nothing
    _startswith(bbid, bbid_prefix) || return nothing
    bb = BlobBatch(B, bbid)
    for frame in preload
        ondemand_loadvframe!(bb, frame)
        ondemand_loaddframe!(bb, frame)
    end
    return bb
end

# returns a channel which iterates for all batches 
# you can filter them
# you can control the order
function _eachbatch_th(B::Bloberia, bbid_prefix = nothing; 
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
                bb = _bb_from_path(B, path, bbid_prefix, preload)
                isnothing(bb) && continue
                put!(_ch, bb)
            end
        end 
    end # Channel
end

function _eachbatch_ser(B::Bloberia, bbid_prefix = nothing; 
        sortfun = identity, 
        ch_size::Int = 1,
        preload = []
    )
    @assert ch_size > 0
    
    # channel
    return Channel{BlobBatch}(ch_size) do _ch
        file_ch = _eachbatchfile_ch(B, 1, sortfun)
        for path in file_ch
            bb = _bb_from_path(B, path, bbid_prefix, preload)
            isnothing(bb) && continue
            put!(_ch, bb)
        end
    end
end

function eachbatch(B::Bloberia, bbid_prefix = nothing; 
        sortfun = identity, 
         ch_size::Int = get(getmeta(B), "eachbatch.ch_size", 1),
        n_tasks::Int = get(getmeta(B), "eachbatch.n_tasks", nthreads()),
        preload = get(getmeta(B), "eachbatch.preload", [])
    )
    if n_tasks > 1
        return _eachbatch_th(B::Bloberia, bbid_prefix; sortfun, ch_size, n_tasks, preload)
    else
        return _eachbatch_ser(B::Bloberia, bbid_prefix; sortfun, ch_size, preload)
    end
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# foreach_batch

# version whiout using channels
function _foreach_batch_chless(f::Function, B::Bloberia)
    bb_root = bloberiapath(B)
    isdir(bb_root) || return nothing
    for path in readdir(bb_root; join = true)
        _isbatchdir(path) || continue
        ret = f(path)
        ret === :break && break
    end
    return nothing
end

function _foreach_batch_ser(f::Function, B::Bloberia, bbid_prefix = nothing; 
        sortfun = identity, 
        ch_size::Int = 1, 
        preload = [], 
        locked = false
    )
    bbs = _eachbatch_ser(B, bbid_prefix; sortfun, ch_size, preload)
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
function _foreach_batch_th(f::Function, B::Bloberia, bbid_prefix = nothing; 
        sortfun = identity, 
        ch_size::Int = 1, 
        n_tasks::Int = nthreads(), 
        preload = [], 
        locked = false
    )

    # channel
    ch = _eachbatch_ser(B, bbid_prefix; sortfun, ch_size, preload)

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

# the execution of `f()` is in concurrent if n_tasks > 1
function foreach_batch(f::Function, B::Bloberia, bbid_prefix = nothing; 
        sortfun = identity, 
        ch_size::Int = get(getmeta(B), "foreach_batch.ch_size", nthreads()), 
        n_tasks::Int = get(getmeta(B), "foreach_batch.n_tasks", nthreads()), 
        preload = get(getmeta(B), "foreach_batch.preload", []),
        locked = get(getmeta(B), "foreach_batch.preload", false),
    )
    if n_tasks > 1
        _foreach_batch_th(f, B, bbid_prefix; sortfun, ch_size, n_tasks, preload, locked)
    else
        _foreach_batch_ser(f, B, bbid_prefix; sortfun, ch_size, preload, locked)
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

