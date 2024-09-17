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
    
    rablob_id::String  # loaded random access file
    rablob::OrderedDict  # loaded random access blob

    temp::OrderedDict   # RAM only
end

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
mutable struct BlobBatch
    B::Bloberia                          # Parent folder
    group::String                        # Batch group (defaul "0")
    uuid::UInt128                        # use UUIDs.uuid4().value
    # disk
    meta::OrderedDict{String, Any}       # config/state/meta in general
    uuids::OrderedSet{UInt128}           # defines which blobs are present
    frames::OrderedDict{String, Any}     # ram frames
    # ram
    temp::OrderedDict             # RAM only
end

## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
# btBlob (a blob in a batch)
# dat [dat/frame/key]
#  |-- "0" 
#       |-- "A" => 1

struct btBlob
    batch::BlobBatch       # owner batch
    uuid::UInt128          # unique universal id
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# raBlob (random access blob)
struct raBlob
    B::Bloberia            # owner batch
    id::String             # user defined id
end




## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 

# ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# # A btBlob is just a Dict like structures.... 
# # Layout
# # dat
# # |-- "lite"
# # |    |-- "0" 
# # |         |-- "A" => 1
# # |
# # |-- "non-lite"
# # |    |-- "0" 
# # |         |-- "B" => [1,2,3,4,5]
# # .
# struct btBlob
#     group::Ref{String}    # currently active group
#     dat::OrderedDict{String, OrderedDict{String, OrderedDict{String, Any}}}
# end

# ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# # IDEAS
# # Empty lites are not allowed
# # btBlob unmutability:
# # - Blobs can not add frames, only BlobBatches/Bloberia
# # - There are two btBlob edit modes: 
# # -- push! (Bloberia): the blob is new
# # -- edit! (Batch iteration): the blob is already in a Blatch
# # - Maybe we need an iter frame, which only contain the btBlob keys.
# # - getindex/setindex! interface should always refer to blobs. 
# # -- at (g)setindex(::btBlob)
# # -- (g)setindex(b::Bloberia) = (g)setindex(b.blob)
# # - lite is a reserved frame.
# # - Add load interface, load(bb, "meta", "lite", "EP.v1")
# # - Change name group -> frame... A frame in the context of a blob means in which frame
# # the data will be written.
# # - load frames in parallel (use @spawn)
# # - iter Bloberia in parrallel (use @spawn)
# # - For random access, maybe I need to add independent blobs
# # -- A can accomplish more or less this by having very short batches
# # -- Yes, at 'meta.jls' I can store the configuration of batches. 
# # --- Or in the name/path
# # -- Also, for fast search, I can have batch namespaces...
# # -- Also for Filtering, I need to create an iterator over sub-batches/batches-blobs/namespaces
# # -- similar to a Bloberia in the sense that it mush have an stage. 
# # -- Maybe a BlobBatch must have an stage also (the current blob). 

# ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# # frames
# # |-- "meta" (file: meta.jls)
# # |    |-- "EP.v1.status" => :DONE
# # |
# # |-- "temp" (ram only)
# # |    |-- "mtime" => 1.718214748856385e9
# # |
# # |-- "lite" (file: lite.frame.jls)
# # |    |-- {"0x1a" => {"alpha" => 1}, "0x2a" => {"alpha" => 4}, ...}
# # |
# # |-- "non-lite" (RAM/DISK)
# # |    |-- "NET0.v1" (file: NET0.v1.non-lite.frame.jls)
# # |         |-- {"0x1a" => {"net0" => NET(...)}, "0x2a" => {"net0" => NET(...)}, ...}
# # |    |-- "EP.v1" (file: EP.v1.non-lite.frame.jls)
# # |         |-- {"0x1a" => {"epm" => EPM(...)}, "0x2a" => {"epm" => EPM(...)}, ...}
# # |
# # .
# struct BlobBatch
#     root::String            # path on disk (if necessary)
#     frames::OrderedDict     # TODO: define type
#     extras::Dict # config/state/etc
# end

# ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# # frames
# # |-- meta.jls 
# # |-- HEAD    (rename to a new batch once full)
# # |-- 0...<h=0x234g>
# # |-- 0...<h=0xf550> 
# # |-- 0...<h=0xa58d> 
# # |-- globals...<h=0xa58d> 
# # .
# struct Bloberia
#     # path
#     root::String                     # path on disk
#     # stage
#     blob::Ref{btBlob}                  # head blob
#     batch::Ref{BlobBatch}            # head batch
#     # meta
#     meta::OrderedDict{String, Any}   # ondisk config/state/stats/etc...
#     # extras
#     extras::Dict                     # config/temps/etc...
# end

# ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# # # Just a wrapper to dispatch context specific methods
# # # TODO: Make blob references: for instance a gropu cold be a ref to other blob group
# # mutable struct Context
# #     group::String                                           # Current open group
# #     dat::OrderedDict{String, OrderedDict{String, Any}}      # "group" => context
# # end
# # Context() = Context("0", OrderedDict())

# ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# # |--- 0...<<h=0x86ff87788a342>>      (batch of group '0')
# #     |--- meta.jls                   (batch meta data [Dict])
# #     |--- 0.lite.jls                 (default 'lite' data frame with name '0' [Vector{Dict}])
# #     |--- 0.non-lite.jls             (default 'non-lite' data frame with name '0' [Vector{Dict}])
# #     |--- bla.frame.jls              (data frame with name 'bla' [Vector{Dict}])
# # mutable struct ContextBatch
# #     # paths
# #     root::String
    
# #     # data
# #     meta::Dict{String, Any}
# #     frames::Dict
    
# #     # data
# #     extras::Dict 
# # end
# # ContextBatch() = ContextBatch("", Dict(), Dict(), Dict())

# # ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# # # Just a wrapper to dispatch blob specific methods
# # mutable struct ContextBlob
# #     dat::OrderedDict{String, Any}
# # end
# # ContextBlob() = ContextBlob(OrderedDict())

# # ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# # mutable struct ContextDB
# #     # paths
# #     root::String
    
# #     # stage [RAM DATA]
# #     ctx::Context                         # current context
# #     stage::ContextBlob                   # current uncommited blob data

# #     # batch
# #     # At set/get actions the loaded current batch is used
# #     # At commit/query new/ondisk batches must be required
# #     batch::ContextBatch
    
# #     # extras
# #     extras::Dict{String, Any}            # spare space

# # end
# # ContextDB(root) = ContextDB(root, Context(), ContextBlob(), ContextBatch(), Dict())
# # ContextDB() = ContextDB("")

# # # import Base.show
# # # Base.show(db::ContextDB) = println(io, "ContextDB(\"", db.root, "\")")
