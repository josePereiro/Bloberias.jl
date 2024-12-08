## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
# The base object
abstract type BlobyObj end

## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
const TEMP_TYPE = OrderedDict{String, Any}
const META_TYPE = OrderedDict{String, Any}
const BLOB_UUIDS_TYPE = OrderedSet{UInt128}
const FRAME_TYPE = OrderedDict{String, Any}
const BB_BFRAMES_TYPE = OrderedDict{String, OrderedDict{UInt128, FRAME_TYPE}}
const BLOB_BFRAMES_TYPE = OrderedDict{String, FRAME_TYPE}
const BB_DFRAMES_TYPE = OrderedDict{String, FRAME_TYPE}

## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
# TODO:
# - implement reset!, which refresh the ram data as it is currently at disk

## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
# Top level object
mutable struct Bloberia <: BlobyObj
    root::String
    meta::META_TYPE         # ram/isk frame
    temp::TEMP_TYPE         # ram frame
end

## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
# An indexable object to interact with data
abstract type AbstractBlob <: BlobyObj end

## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
# BlobBatch
# =================
# Disk/Data layout
# B (Bloberia)
# |- ./bb0 (BlobBatch)
# .   |- ./meta.jls
# .   |- ./0.bbframe.jls         {...}
# .         |- "key0" => dat0
#           |- "key1" => dat1
#           |- ...
#     |- ./custom.bbframe.jls    {...}
#     |- ./buuids.jls       {uuid0 => {...}, uuid1 => {...}, ...}
#           |- uuid0
#               |- "key00" => dat0
#               |- ...
#           |- uuid1
#               |- "key10" => dat0
#               |- ...
#     |- ./0.bframe.jls         {uuid0 => {...}, uuid1 => {...}, ...}
#     |- ./custom.bframe.jls    {uuid0 => {...}, uuid1 => {...}, ...}
#     |- ...

# =================
# Ram layout
# B (Bloberia)
# |- bb0 (BlobBatch)
#     |- meta
#           |- "key0" => dat0
#           |- "key1" => dat1
#           |- ...
#     |- temp
#           |- "key0" => dat0
#           |- "key1" => dat1
#           |- ...
#     |- bbframes
#           |- "frame0" 
#                  |- "key0" => dat0
#                  |- "key1" => dat1
#           |- ...
#     |- bframes
#           |- "frame0" 
#                   |- uuid0 
#                       |- "key0" => dat0
#                       |- "key1" => dat1
#                   |- uuid1
#                       |- "key0" => dat0
#                       |- "key1" => dat1
#           |- ...
#     |- ...
# |- ...

# =================
# interface layout
# B (Bloberia)
# |- bb0 (BlobBatch)
# .   |- meta
# .   |   |- key
# .   |
#     |- bbframe (dblob)
#     |   |- key
#     |
#     |- uuid0 (Blob)
#     .   |- bframe
#     .        |- key
#     .
mutable struct BlobBatch <: AbstractBlob
    # Parent folder
    B::Bloberia    
    id::String
    
    ## meta (disk)
    # - config/state/meta in general
    meta::META_TYPE              # {...}
    ## bbframes
    bbframes::BB_DFRAMES_TYPE        # {"frame0" => {...}, ...}
    ## bframes (disk)
    # - defines which blobs are present
    buuids::BLOB_UUIDS_TYPE             # [uuid0, uuid1, ...]
    # - ram copy of frames
    bframes::BB_BFRAMES_TYPE        # {"frame0" => {uuid => {...}, ...}, ...}
    # ram
    temp::TEMP_TYPE              # {...}
end

## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
# This is an object defined across different bframes
struct Blob <: AbstractBlob
    bb::BlobBatch          # owner batch
    uuid::UInt128          # unique universal id
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# TODO: Complete signature BlobyRef{lT, rT} where {lT::Symbol, rT<:Any}
struct BlobyRef{lT, rT}
    link::Dict{String, Any}  # All coordinates   
    BlobyRef(ltype::Symbol, rtype::DataType) = new{ltype, rtype}(Dict())
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# allow ref rolling
struct RefCacher
    bb_cache::Dict{String, BlobBatch}   # path => bb
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
nothing