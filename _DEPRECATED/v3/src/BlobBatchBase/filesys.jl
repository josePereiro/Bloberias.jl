## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# filesys

# file: meta.jls
_meta_framepath(dir) = joinpath(dir, "meta.jls")
# file: uuids.jls
_uuids_framepath(dir) = joinpath(dir, "uuid.blobs.jls")
# file: lite.frame.jls
_lite_framepath(dir) = joinpath(dir, "lite.blobs.jls")
# file: NET0.v1.non-lite.frame.jls
_nonlite_framepath(dir, group) = joinpath(dir, string(group, ".nonlite.blobs.jls"))


function _isbatchdir(path)
    isdir(path) || return false
    isfile(_meta_framepath(path)) && return true
    isfile(_uuids_framepath(path)) && return true
    return false
end

_batchpath(dir, group, uuid) = joinpath(dir, string(group, ".", uuid))

function _split_batchname(path)
    base = basename(path)
    group, uuid = splitext(base)
    uuid = strip(uuid, '.')
    return group, uuid
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

function lite_framepath(bb::BlobBatch) 
    dir = batchpath(bb)
    isempty(dir) && return ""
    return _lite_framepath(dir)
end

function nonlite_framepath(bb::BlobBatch, group)
    dir = batchpath(bb)
    isempty(dir) && return ""
    return _nonlite_framepath(dir, group)
end
