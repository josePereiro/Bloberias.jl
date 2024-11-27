# The blobbatch iterate accross the blobs

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
function eachblob(bb::BlobBatch)
    return Channel{vBlob}(0) do _ch
        vuuids = getvuuids(bb)
        for uuid in vuuids
            # I do not need to check if blob exist
            b = vBlob(bb, uuid) 
            put!(_ch, b)
        end
    end
end

# --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Iterator
function _bb_iterate_next(ch::Channel, ch_next)
    isnothing(ch_next) && return nothing
    item, ch_state = ch_next
    bb_state = (ch, ch_state)
    return (item, bb_state)
end

import Base.iterate
function Base.iterate(bb::BlobBatch)
    ch = eachblob(bb)
    ch_next = iterate(ch)
    return _bb_iterate_next(ch, ch_next)
end

function Base.iterate(::BlobBatch, bb_state) 
    isnothing(bb_state) && return nothing
    ch, ch_state = bb_state
    ch_next = iterate(ch, ch_state)
    return _bb_iterate_next(ch, ch_next)
end

import Base.length
Base.length(bb::BlobBatch) = vblobcount(bb)