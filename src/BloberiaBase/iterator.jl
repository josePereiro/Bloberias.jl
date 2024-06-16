## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# returns a channel which iterates for all batches 
# you can filter them
# you can control the order
function batches(B::Bloberia, group_pt = nothing; 
        sortfun = identity, 
        ch_size::Int = nthreads(), 
        preload = []
    )
    @assert ch_size > 0
    return Channel{BlobBatch}(ch_size) do _ch
        paths = sortfun(readdir(B.root; join = true))
        n = ceil(Int, length(paths) / ch_size)
        ts = map(Iterators.partition(paths, n)) do t_paths
            Threads.@spawn for path in t_paths
                _isbatchdir(path) || continue
                group, uuid = _split_batchname(path)
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
        foreach(wait, ts)
    end
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# foreach_batch
# TODO: make all this multithreading and race safe
function foreach_batch(f::Function, B::Bloberia, group_pt = nothing; 
        sortfun = identity, 
        ch_size::Int = nthreads(), 
        preload = []
    )
    ret = nothing
    bbs = batches(B, group_pt; sortfun, ch_size, preload)
    for bb in bbs
        ret = f(bb)
        ret === :break && break
    end
    return ret
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
    ch = batches(B)
    ch_next = iterate(ch)
    return _B_iterate_next(ch, ch_next)
end

function Base.iterate(::Bloberia, B_state) 
    isnothing(B_state) && return nothing
    ch, ch_state = B_state
    ch_next = iterate(ch, ch_state)
    return _B_iterate_next(ch, ch_next)
end

