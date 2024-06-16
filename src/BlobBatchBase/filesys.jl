## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# filesys

# file: meta.jls
_meta_framepath(dir) = joinpath(dir, "meta.jls")
# file: uuids.jls
_uuids_framepath(dir) = joinpath(dir, "uuid.blobs.jls")
# file: NET0.v1.non-lite.frame.jls
_dat_framepath(dir, frame) = joinpath(dir, string(frame, ".frame.jls"))

function _isbatchdir(path)
    isdir(path) || return false
    isfile(_meta_framepath(path)) && return true
    isfile(_uuids_framepath(path)) && return true
    return false
end

_batchpath(dir, group, uuid) = joinpath(dir, string(group, ".", uuid))

function _split_batchname(path)
    base = basename(path)
    frame, uuid = splitext(base)
    uuid = strip(uuid, '.')
    return frame, uuid
end

function _hasfilesys(bb::BlobBatch)
    _hasfilesys(bb.B) || return false
    isempty(string(bb.group)) && return false
    isempty(bb.uuid) && return false
    return true
end

function batchpath(bb::BlobBatch) 
    _hasfilesys(bb) || return ""
    return _batchpath(bb.B.root, bb.group, bb.uuid)
end

function meta_framepath(bb::BlobBatch) 
    dir = batchpath(bb)
    isempty(dir) && return ""
    return _meta_framepath(dir)
end

function uuids_framepath(bb::BlobBatch) 
    dir = batchpath(bb)
    isempty(dir) && return ""
    return _uuids_framepath(dir)
end

function dat_framepath(bb::BlobBatch, frame)
    dir = batchpath(bb)
    isempty(dir) && return ""
    return _dat_framepath(dir, frame)
end
