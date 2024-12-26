## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Constructor

BlobBatch(B::Bloberia, id) = BlobBatch(B, id,
    _batchpath(B.root, id),  # root
    FRAMES_DEPOT_TYPE(),
    DICT_DEPOT_TYPE()
)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# shallow copy 
Base.copy(bb::BlobBatch) = BlobBatch(bb.B, bb.id)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# file sys

# build path
_batchpath(B_root::String, id::String) = joinpath(B_root, id)

_blobypath(bb::BlobBatch) = bb.root

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# BlobyObj interface

bloberia(bb::BlobBatch) = bb.B
blobbatch(bb::BlobBatch) = bb
batchpath(bb::BlobBatch) = bb.root
batchpath(bo::BlobyObj) = batchpath(blobbatch(bo))

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# An identity hash for the object
function _lock_obj_identity_hash(bb::BlobBatch, h0 = UInt64(0))::UInt64
    h = hash(h0)
    h = hash(:BlobBatch, h)
    h = hash(batchpath(bb), h)
    return h
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# close/open interface
# if it close it should be read only
# serialization must fail
# TODO: think per frame close (maybe a readonly flag)
import Base.isopen
function Base.isopen(bb::BlobBatch)
    return get(getmeta(bb), "bb.isopen", true)::Bool
end

function open!(bb::BlobBatch)
    setindex!(getmeta(bb), true, "bb.isopen")
end

function close!(bb::BlobBatch)
    setindex!(getmeta(bb), false, "bb.isopen")
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# TODO: add tests
import Base.rm
function Base.rm(bb::BlobBatch)
    rm(batchpath(bb); force = true, recursive = true)
end

import Base.filesize
function Base.filesize(bb::BlobBatch)
    return _recursive_filesize(batchpath(bb))
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# hashio!
hashio!(bb::BlobBatch, val, mode = :getser!; 
    prefix = "cache", 
    hashfun = hash, 
    abs = true, 
) = _hashio!(bb, val, mode; prefix, hashfun, abs)

