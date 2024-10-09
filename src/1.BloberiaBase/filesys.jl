## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# filesys

function hasfilesys(B::Bloberia)
    isempty(B.root) && return false
    return true
end

bloberia_dir(B::Bloberia) = _joinpath_err(B)
meta_framepath(B::Bloberia) = _joinpath_err(B, "meta.jls")
blobbatches_dir(B::Bloberia) = _joinpath_err(B, "batches")
rablobs_dir(B::Bloberia) = _joinpath_err(B, "rablobs")

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Utils

function _joinpath_err(B::Bloberia, as...)
    hasfilesys(B) || error("No file system setup.")
    return joinpath(B.root, as...)
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# file interface

import Base.rm
Base.rm(B::Bloberia; force = true) = 
    hasfilesys(B) && rm(B.root; force,  recursive = true)

function Base.rm(B::Bloberia, group_pt; force = true)
    hasfilesys(B) || return
    for bb in eachbatch(B, group_pt)
        rm(bb; force)
    end
end

import Base.mkpath
Base.mkpath(B::Bloberia; kwargs...) = mkpath(B.root; kwargs...)

import Base.filesize
function Base.filesize(B::Bloberia)
    fsize = 0.0;
    # TODO: add raBlobs
    foreach_batch(B) do bb
        fsize += filesize(bb)
    end
    return fsize
end
