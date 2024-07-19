## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
const BLOBERIA_DEFAULT_BATCH_GROUP = "0"
const BLOBERIA_DEFAULT_FRAME_NAME = "0"

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Constructor
Bloberia(root) = Bloberia(root, OrderedDict(), OrderedDict())
Bloberia() = Bloberia("")

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
import Base.show
function Base.show(io::IO, B::Bloberia)
    if _hasfilesys(B)
        print(io, "Bloberia with ", batchcount(B), " batch(es), ", blobcount(B), " blob(s)")
        print(io, "\nfilesys: ", B.root)
        val, unit = _canonical_bytes(filesize(B))
        print(io, "\ndisk usage: ", round(val; digits = 3), " ", unit)
    else
        print(io, "Bloberia: filesys not found...")
    end
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
import Base.getindex
# uuid indexing
function Base.getindex(B::Bloberia, uuid0::UInt128)
    for bb in B
        bb.uuid == uuid0 && return bb
    end
    error("Batch not found, uuid: ", repr(uuid0))
end

# order indexing
# WARNING: order is not controlled
function Base.getindex(B::Bloberia, idx::Integer)
    @assert idx > 0
    batchcount = 0
    for (i, bb) in enumerate(B)
        i == idx && return bb
        batchcount += 1
    end
    @assert idx <= batchcount
end
# collect fallback
function Base.getindex(B::Bloberia, idx)
    bbs = collect(eachbatch(B))
    return bbs[idx]
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Use, uuids
function blobcount(B::Bloberia, group_pt = nothing)
    count = 0
    bbs = eachbatch(B, group_pt)
    for bb in bbs
        count += blobcount(bb)
    end
    return count
end
