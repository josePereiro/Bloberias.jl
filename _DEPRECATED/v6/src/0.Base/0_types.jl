#TODO: check https://docs.julialang.org/en/v1/base/collections/#Dictionaries for cool Dictlike datatypes

## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
# The base object
abstract type BlobyObj end

# IDEA: dev ContextDB interface in another package
# - It can run on top of Bloberia

## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
# depot types
const UUIDS_DEPOT_TYPE = OrderedSet{UInt128}
const DICT_DEPOT_TYPE = OrderedDict{String, Any}
const VECDICT_DEPOT_TYPE = OrderedDict{UInt128, DICT_DEPOT_TYPE}

# frames id/fT
const bUUIDS_FRAMEID = "buuids"
const bUUIDS_FRAME_TYPE = :buuids

const META_FRAMEID = "meta"
const META_FRAME_TYPE = :meta

const B_BFRAME_FRAME_TYPE = :Bframe
const bb_bFRAME_FRAME_TYPE = :bframe
const bb_bbFRAME_FRAME_TYPE = :bbframe
const b_uFRAME_FRAME_TYPE = :uframe   # frame of a blob

## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
# File wrapper
# fT::Symbol Frame type 
# dT dat Type 
struct BlobyFrame{fT, dT} <: BlobyObj
    id::String   # id
    dat::dT      # content
end

const FRAMES_DEPOT_TYPE = Dict{String, BlobyFrame}

## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
# An indexable object to interact with data
abstract type AbstractBlob <: BlobyObj end

## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
# TODO: copy pkg README into Bloberia

# Top level object
struct Bloberia <: AbstractBlob
    root::String
    frames::FRAMES_DEPOT_TYPE    # ram/disk frame
    temp::DICT_DEPOT_TYPE              # ram only frame
end

## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
# BlobBatch
# #TODO: Add layout comment (see _DEPRECATED)
# =================
# Disk/Data layout
# B (Bloberia)
# ...
struct BlobBatch <: AbstractBlob
    B::Bloberia     # Parent folder
    id::String
    root::String
    frames::FRAMES_DEPOT_TYPE    # ram/disk frame
    # ram only
    temp::DICT_DEPOT_TYPE
end

## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
# This is an object defined across different bframes
struct Blob <: AbstractBlob
    bb::BlobBatch          # owner batch
    uuid::UInt128          # unique universal id
    function Blob(bb, uuid)
        new(bb, UInt128(uuid))
    end
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
struct BlobyRef{lT, rT} <: BlobyObj
    link::Dict{String, Any}  # All coordinates   
    BlobyRef(ltype::Symbol, rtype::DataType) = new{ltype, rtype}(Dict())
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# allow ref rolling
struct RefCacher <: BlobyObj
    depot_cache::Dict{UInt, AbstractBlob}   # path => bb
end

# ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# nothing