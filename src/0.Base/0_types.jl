## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
# frames
# |-- meta.jls 
# | # random access blobs
# interface B["string.idx"]
# The frame will have a fix name
# |-- rablob...<h=0x0001>
# | # batch accessed blobs
# |-- 0...<h=0x234g>
# |-- 0...<h=0xf550> 
# |-- 0...<h=0xa58d> 
# |-- custom_group...<h=0xa58d> 
# .
mutable struct Bloberia
    root::String
    meta::OrderedDict   # Persistants blob
    temp::OrderedDict   # RAM only
end

## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
# TODO: dry some code using AbstractFramedBlob
# ex: getframe
abstract type AbstractFramedBlob end

## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
# BlobBatch
# meta (file: meta.jls)
#   |-- {"EP.v1.status" => :DONE, ...}

# uuids (file: uuids.jls)
#   |-- [0x1a, 0xf1, ...]

#  frames [frames/frame/blob_uuid/key]
#   |-- "NET0.v1" (file: NET0.v1.non-lite.frame.jls)
#   |    |-- {0x1a => {"net0" => NET(...), ...}, 0xf1 => {"net0" => NET(...), ...}, ...}
#   |
#   |-- "EP.v1" (file: EP.v1.non-lite.frame.jls)
#        |-- {0x1a => {"epm" => EPM(...), ...}, 0xf1 => {"epm" => EPM(...), ...}, ...}

# temp (ram only)
#   |-- {"mtime" => 1.718214748856385e9, ...}

# TODO: define types
mutable struct BlobBatch <: AbstractFramedBlob
    B::Bloberia                          # Parent folder
    group::String                        # Batch group (defaul "0")
    uuid::UInt128                        # use UUIDs.uuid4().value
    # disk
    meta::OrderedDict{String, Any}       # config/state/meta in general
    uuids::OrderedSet{UInt128}           # defines which blobs are present
    frames::OrderedDict{String, Any}     # ram frames
    # ram
    temp::OrderedDict                    # RAM only
end

## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
# TODO: dry some code using AbstractBlob
# ex: getframe
abstract type AbstractBlob <: AbstractFramedBlob end

## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
# btBlob (a blob in a batch)
# dat [dat/frame/key]
#  |-- "0" 
#       |-- "A" => 1

struct btBlob <: AbstractBlob
    batch::BlobBatch       # owner batch
    uuid::UInt128          # unique universal id
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# raBlob (random access blob)
struct raBlob <: AbstractBlob
    B::Bloberia                      # owner batch
    id::String                       # user defined id
    meta::OrderedDict{String, Any}   # config/state/meta in general
    frames::OrderedDict              # loaded data blob
    # ram
    temp::OrderedDict                # RAM only
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# TODO: Complete signature BlobyRef{lT, rT} where {lT::Symbol, rT<:Any}
struct BlobyRef{lT, rT}
    link::Dict{String, Any}  # All coordinates   
    BlobyRef(ltype::Symbol, rtype::DataType) = new{ltype, rtype}(Dict())
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
nothing