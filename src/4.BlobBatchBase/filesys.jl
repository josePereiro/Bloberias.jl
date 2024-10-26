## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# filesys

function hasfilesys(bb::BlobBatch, checkB = true)
    checkB && (hasfilesys(bb.B) || return false)
    isempty(string(bb.group)) && return false
    isempty(bb.uuid) && return false
    return true
end

batchpath(bb::BlobBatch) = _joinpath_err(bb)

meta_framepath(bb::BlobBatch) = _bb_meta_framepath(batchpath(bb))
dat_framepath(bb::BlobBatch, frame) = _bb_dat_framepath(batchpath(bb), frame)
uuids_framepath(bb::BlobBatch) = _bb_uuids_framepath(batchpath(bb))

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Utils

function _joinpath_err(bb::BlobBatch, as...)
    hasfilesys(bb, false) || error("No file system setup.")
    root = blobbatches_dir(bb.B)
    return joinpath(root, string(bb.group, ".", repr(bb.uuid)), as...)
end

function _isbatchdir(path)
    isdir(path) || return false
    isfile(_bb_meta_framepath(path)) && return true
    isfile(_bb_uuids_framepath(path)) && return true
    return false
end

function _split_batchname(path)
    base = basename(path)
    frame, uuid = splitext(base)
    uuid = strip(uuid, '.')
    return frame, uuid
end

_bb_meta_framepath(root::String) = joinpath(root, "meta.jls")
_bb_dat_framepath(root::String, frame) = joinpath(root, string(frame, ".frame.jls"))
_bb_uuids_framepath(root::String) = joinpath(root,  "uuid.blobs.jls")

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
import Base.isdir
Base.isdir(bb::BlobBatch) = isdir(batchpath(bb))

import Base.filesize
function Base.filesize(bb::BlobBatch)
    fsize = 0.0;
    for fn in readdir(batchpath(bb); join = true)
        isfile(fn) || continue
        endswith(basename(fn), ".jls") || continue
        fsize += filesize(fn)
    end
    return fsize
end

import Base.rm
Base.rm(bb; force = true) = rm(batchpath(bb); force, recursive = true)