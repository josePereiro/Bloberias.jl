## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# filesys

function hasfilesys(bb::BlobBatch)
    hasfilesys(bb.B) || return false
    isempty(bb.id) && return false
    return true
end

function batchpath(bb::BlobBatch) 
    return get!(bb.temp, "bb.path") do
        _joinpath_err(bb)
    end
end

meta_jlspath(bb::BlobBatch) = get!(bb.temp, "meta_jlspath") do
    _bb_meta_jlspath(batchpath(bb))
end

vuuids_jlspath(bb::BlobBatch) = get!(bb.temp, "vuuids_jlspath") do
    _bb_vuuids_jlspath(batchpath(bb))
end
vframe_jlspath(bb::BlobBatch, frame) = get!(bb.temp, string("vframe_jlspath.", frame)) do
    _bb_vframe_jlspath(batchpath(bb), frame)
end
dframe_jlspath(bb::BlobBatch, frame) = get!(bb.temp, string("dframe_jlspath.", frame)) do
    _bb_dframe_jlspath(batchpath(bb), frame)
end


## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Utils
_batchpath(B_root, bb_id) = joinpath(B_root, bb_id)

function _joinpath_errless(bb::BlobBatch, as...)
    return joinpath(_batchpath(bb.B.root, bb.id), as...)
end
function _joinpath_err(bb::BlobBatch, as...)
    hasfilesys(bb) || error("No file system setup.")
    return _joinpath_errless(bb, as...)
end

# TODO: Think ablut it, 
# - allow empty dirs
# - maybe just check that your parent is a Bloberia forlder
# function _isbatchdir(path)
    # isdir(path) || return false
    # isfile(_bb_meta_jlspath(path)) && return true
    # isfile(_bb_vuuids_jlspath(path)) && return true
#     return false
# end

_isbatchdir(path) = isdir(path)

function _isbatchdir(B::Bloberia, path)
    root = bloberiapath(B)
    return startswith(path, root)
end

_bb_meta_jlspath(root::String) = joinpath(root, "meta.jls")
_bb_vframe_jlspath(root::String, frame) = joinpath(root, string(frame, ".vframe.jls"))
_bb_dframe_jlspath(root::String, frame) = joinpath(root, string(frame, ".dframe.jls"))
_bb_vuuids_jlspath(root::String) = joinpath(root,  "vuuids.jls")

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
import Base.isdir
Base.isdir(bb::BlobBatch) = isdir(batchpath(bb))

import Base.filesize
function Base.filesize(bb::BlobBatch)
    return _recursive_filesize(batchpath(bb))
end

import Base.rm
Base.rm(bb; force = true) = rm(batchpath(bb); force, recursive = true)

import Base.mkpath
Base.mkpath(bb::BlobBatch; kwargs...) = mkpath(batchpath(bb); kwargs...)
