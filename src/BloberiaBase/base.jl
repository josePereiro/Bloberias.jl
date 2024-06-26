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
        count = batchcount(B)
        print(io, "Bloberia with ", count, " batch(es)")
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
    bbs = collect(batches(B))
    return bbs[idx]
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# filesys
function _hasfilesys(B::Bloberia)
    isempty(B.root) && return false
    return true
end

import Base.rm
Base.rm(B::Bloberia; force = true, recursive = true) = 
    _hasfilesys(B) && rm(B.root; force, recursive)

import Base.mkpath
Base.mkpath(B::Bloberia; kwargs...) = mkpath(B.root; kwargs...)

import Base.filesize
function Base.filesize(B::Bloberia)
    fsize = 0.0;
    foreach_batch(B) do bb
        fsize += filesize(bb)
    end
    return fsize
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Use, uuids
# function blobcount(B::Bloberia)
#     count = 0
#     for bb in bbs
#     end
# end

