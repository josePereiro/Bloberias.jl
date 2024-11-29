## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
# The base object
abstract type BlobyObj end

## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
const TEMP_TYPE = OrderedDict{String, Any}
const META_TYPE = OrderedDict{String, Any}
const VUUIDS_TYPE = OrderedSet{UInt128}
const VFRAMES_TYPE = OrderedDict{String, OrderedDict{UInt128, OrderedDict}}
const DFRAMES_TYPE = OrderedDict{String, OrderedDict}


## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
# Top level object
mutable struct Bloberia <: BlobyObj
    root::String
    meta::META_TYPE         # Disk frame
    temp::TEMP_TYPE         # RAM only
end

## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
# BlobBatch
# =================
# Disk/Data layout
# B (Bloberia)
# |- ./bb0 (BlobBatch)
# .   |- ./meta.jls
# .   |- ./0.dframe.jls         {...}
# .         |- "key0" => dat0
#           |- "key1" => dat1
#           |- ...
#     |- ./custom.dframe.jls    {...}
#     |- ./vblobs.ids.jls       {uuid0 => {...}, uuid1 => {...}, ...}
#           |- uuid0
#               |- "key00" => dat0
#               |- ...
#           |- uuid1
#               |- "key10" => dat0
#               |- ...
#     |- ./0.vframe.jls         {uuid0 => {...}, uuid1 => {...}, ...}
#     |- ./custom.vframe.jls    {uuid0 => {...}, uuid1 => {...}, ...}
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
#     |- dframes
#           |- "frame0" 
#                  |- "key0" => dat0
#                  |- "key1" => dat1
#           |- ...
#     |- vframes
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
#     |- dframe (dblob)
#     |   |- key
#     |
#     |- uuid0 (vBlob)
#     .   |- vframe
#     .        |- key
#     .
mutable struct BlobBatch <: BlobyObj
    # Parent folder
    B::Bloberia    
    id::String
    
    ## meta (disk)
    #- config/state/meta in general
    meta::META_TYPE              # {...}
    ## dframes
    dframes::DFRAMES_TYPE        # {"frame0" => {...}, ...}
    ## vframes (disk)
    #- defines which vblobs are present
    vuuids::VUUIDS_TYPE          # [uuid0, uuid1, ...]
    #- ram copy of frames
    vframes::VFRAMES_TYPE        # {"frame0" => {uuid => {...}, ...}, ...}
    # ram
    temp::TEMP_TYPE              # {...}
end

## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
abstract type AbstractBlob <: BlobyObj end

## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
# This is an object defined across different vframes
struct vBlob <: AbstractBlob
    bb::BlobBatch       # owner batch
    uuid::UInt128          # unique universal id
end

## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
# Just a wrapper of bb.dframes
struct dBlob <: AbstractBlob
    bb::BlobBatch       # owner batch
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
    RefCacher() = new(Dict())
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
nothing