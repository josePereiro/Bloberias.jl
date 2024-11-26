## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Constructor
BlobBatch(B::Bloberia, id) = BlobBatch(B, id,
    OrderedDict(), # meta
    OrderedDict(), # dframes
    OrderedSet(),  # vuuids
    OrderedDict(), # vframes
    OrderedDict()  # temp
)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# shallow copy 
Base.copy(bb::BlobBatch) = BlobBatch(bb.B, bb.id)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# obj struct interface
bloberia(bb::BlobBatch) = bb.B
blobbatch(bb::BlobBatch) = bb

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# close/open interface
# if it close it should be read only
# serialization must fail
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

# ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# function _bb_show_file_sortby(ph)
#     name = basename(ph)
#     name == "uuid.blobs.jls" && return "."
#     name == "meta.jls" && return ".."
#     return name
# end

# import Base.show
# function Base.show(io::IO, bb::BlobBatch)
#     print(io, "BlobBatch(", repr(bb.uuid), ")")
#     hasfilesys(bb) || return
#     _pretty_print_pairs(io, 
#         "\n filesys", 
#         basename(batchpath(bb))
#     )
#     _pretty_print_pairs(io, 
#         "\n blob(s)", 
#         vblobcount(bb)
#     )
#     if !isempty(bb.frames)
#         print(io, "\nRam frames: ")
#         for (frame, _bb_frame) in bb.frames
#             isempty(_bb_frame) && continue
#             kT_pairs = Set()
#             for (_, _b_frame) in _bb_frame
#                 for (key, val) in _b_frame
#                     push!(kT_pairs, string(key) => typeof(val))
#                 end
#             end
#             print(io, "\n \"", frame, "\" ")
#             _kv_print_type(io, kT_pairs; _typeof = identity)
#         end
#     end

#     if isdir(bb)
#         _bb_filesize = 0.0
#         print(io, "\nDisk frames: ")
#         b_files = readdir(batchpath(bb); join = true)
#         sort!(b_files; by = _bb_show_file_sortby)
#         for path in b_files
#             endswith(path, ".frame.jls") || continue
#             _filesize = filesize(path)
#             val, unit = _canonical_bytes(_filesize)
#             print(io, "\n  \"", basename(path), "\" ")
#             print(io, "[")
#             printstyled(io, string(round(val; digits = 3), " ", unit);
#                 color = :blue
#             )
#             print(io, "]")
#             _bb_filesize += _filesize
#         end
#         val, unit = _canonical_bytes(_bb_filesize)
#         print(io, "\ndisk usage: ")
#         printstyled(io, string(round(val; digits = 3), " ", unit);
#             color = :blue
#         )
#     end

# end

# ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# # getindex

# import Base.getindex
# Base.getindex(bb::BlobBatch, uuid::UInt128) = blob(bb, uuid) 
# Base.getindex(bb::BlobBatch, i::Int) = blob(bb, i)

# # isempty
# function Base.isempty(bb::BlobBatch)
#     ondemand_loadvuuids!(bb)
#     return isempty(bb.vuuids)
# end

# # isempty
# import Base.empty!
# function Base.empty!(bb::BlobBatch)
#     empty!(bb.meta)
#     empty!(bb.vuuids)
#     empty!(bb.temp)
#     empty!(bb.frames)
#     return nothing
# end

# ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# # Set the batch limit

# function isfullbatch(bb::BlobBatch) 
#     B_lim = getmeta(bb.B, "batches.blobs.lim", typemax(Int))::Int
#     bb_lim = getmeta(bb, "blobs.lim", typemax(Int))::Int
#     lim = min(B_lim, bb_lim)
#     return vblobcount(bb) >= lim
# end
