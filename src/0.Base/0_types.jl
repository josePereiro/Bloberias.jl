#TODO: check https://docs.julialang.org/en/v1/base/collections/#Dictionaries for cool Dictlike datatypes

## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
# The base object
abstract type BlobyObj end

# IDEA: dev ContextDB interface in another package
# - It can run on top of a Bloberia

## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
const TEMP_DEPOT_TYPE = OrderedDict{String, Any}

const bUUIDS_DEPOT_TYPE = OrderedSet{UInt128}
const bUUIDS_FRAMEID = "buuids"
const bUUIDS_FRAME_TYPE = :buuids

const META_DEPOT_TYPE = OrderedDict{String, Any}
const META_FRAMEID = "meta"
const META_FRAME_TYPE = :meta

const BLOB_DEPOT_TYPE = OrderedDict{String, Any}
const ABS_FRAME_DEPOT_TYPE = OrderedDict
const VFRAME_DEPOT_TYPE = OrderedDict{UInt128, BLOB_DEPOT_TYPE}
const DFRAME_DEPOT_TYPE = BLOB_DEPOT_TYPE

const B_BFRAME_FRAME_TYPE = :Bframe
const bb_bFRAME_FRAME_TYPE = :bframe
const bb_bbFRAME_FRAME_TYPE = :bbframe
const b_uFRAME_FRAME_TYPE = :uframe   # frame of a blob

## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
# File wrapper
# fT::Symbol Frame type 
# dT dat Type 
struct BlobyFrame{fT, dT} <: BlobyObj
    bo::BlobyObj # parent
    id::String   # id
    path::String # path
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
    temp::TEMP_DEPOT_TYPE              # ram only frame
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
    temp::TEMP_DEPOT_TYPE
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