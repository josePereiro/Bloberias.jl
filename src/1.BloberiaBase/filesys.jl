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
Base.rm(B::Bloberia; force = true) = rm(B.root; force,  recursive = true)

function Base.rm(B::Bloberia, group_pt; force = true)
    for bb in eachbatch(B, group_pt)
        rm(bb; force)
    end
end

import Base.mkpath
Base.mkpath(B::Bloberia; kwargs...) = mkpath(B.root; kwargs...)

# filesize
function rablobs_filesize(B::Bloberia)
    fsize = 0.0
    rabs = rablobs_dir(B)
    for fn in readdir(rabs; join=true)
        isfile(fn) || continue
        endswith(basename(fn), ".jls") || continue
        fsize += filesize(fn)
    end
    return fsize
end

function blobatches_filesize(B::Bloberia)
    fsize = 0.0
    for bb in B
        fsize += filesize(bb)
    end
    return fsize
end

import Base.filesize
function Base.filesize(B::Bloberia)
    fsize = 0.0
    fsize += blobatches_filesize(B)
    fsize += rablobs_filesize(B)
    return fsize
end