## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# filesys

function hasfilesys(B::Bloberia)
    isempty(B.root) && return false
    return true
end

bloberiapath(B::Bloberia) = _joinpath_err(B)
meta_jlspath(B::Bloberia) = _joinpath_err(B, "meta.jls")

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Utils

function _joinpath_err(B::Bloberia, as...)
    hasfilesys(B) || error("No file system setup.")
    return joinpath(B.root, as...)
end

function _joinpath_errless(B::Bloberia, as...)
    return joinpath(B.root, as...)
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# file interface

import Base.joinpath
Base.joinpath(B::Bloberia, as...) = _joinpath_err(B, as...)

import Base.rm
Base.rm(B::Bloberia; force = true) = rm(B.root; force,  recursive = true)

function Base.rm(B::Bloberia, bbid_pt; force = true)
    for bb in eachbatch(B, bbid_pt)
        rm(bb; force)
    end
end

import Base.mkpath
Base.mkpath(B::Bloberia; kwargs...) = mkpath(B.root; kwargs...)

# # filesize
# function rablobs_filesize(B::Bloberia)
#     fsize = 0.0
#     rabs = rablobs_dir(B)
#     isdir(rabs) || return fsize
#     for fn in readdir(rabs; join=true)
#         isfile(fn) || continue
#         endswith(basename(fn), ".jls") || continue
#         fsize += filesize(fn)
#     end
#     return fsize
# end

# function blobatches_filesize(B::Bloberia)
#     fsize = 0.0
#     for bb in B
#         fsize += filesize(bb)
#     end
#     return fsize
# end

import Base.filesize
function Base.filesize(B::Bloberia)
    return _recursive_filesize(bloberiapath(B))
end