## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
const BLOBERIA_DEFAULT_RABLOB_ID = "0"
const BLOBERIA_DEFAULT_BATCH_GROUP = "0"
const BLOBERIA_DEFAULT_FRAME_NAME = "0"

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Constructor
Bloberia(root) = Bloberia(root, OrderedDict(), OrderedDict())
Bloberia() = Bloberia("")

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
bloberia(bo::Bloberia) = bo

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
import Base.show
function Base.show(io::IO, B::Bloberia)
    print(io, "Bloberia")
    _isdir = isdir(B.root)
    _pretty_print_pairs(io, 
        "\n filesys", 
        hasfilesys(B) ? B.root : ""
    )
    _pretty_print_pairs(io, 
        "\n batch(es)", 
        _isdir ? batchcount(B) : 0
    )
    _pretty_print_pairs(io, 
        "\n blob(s)", 
        _isdir ? blobcount(B) : 0
    )
    val, unit = _isdir ? _canonical_bytes(filesize(B)) : (0.0, "bytes")
    _pretty_print_pairs(io, 
        "\n disk usage", 
        _isdir ? string(round(val; digits = 3), " ", unit) : 0.0
    )
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# import Base.getindex
# # uuid indexing

# # TODO: think abount a batchs.jls for tracking existing batches
# Base.getindex(B::Bloberia, uuid0::UInt128) = blobbatch(B, uuid0) # existing batch

# # order indexing
# # WARNING: order is not controlled
# Base.getindex(B::Bloberia, idx::Integer) = blobbatch(B, idx) # existing batch
    
# # collect fallback
# function Base.getindex(B::Bloberia, idx)
#     bbs = collect(eachbatch(B))
#     return bbs[idx]
# end

# Base.getindex(B::Bloberia, key::String) = blob(B, key) # random access blob
# Base.getindex(B::Bloberia) = blob!(B, BLOBERIA_DEFAULT_RABLOB_ID) # random access blob!


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

