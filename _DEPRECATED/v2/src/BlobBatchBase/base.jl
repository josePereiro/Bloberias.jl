## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Constructor
BlobBatch(root) = BlobBatch(root, Dict(), Dict())
BlobBatch() = BlobBatch("")

# --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# filesys
dirpath(bb::BlobBatch) = bb.root

import Base.isdir
Base.isdir(bb::BlobBatch) = isdir(dirpath(bb))

metaframe_name() = "meta.jls"
liteframe_name(k::String) = string(k, ".lite.frame.jls")
nonliteframe_name(k::String) = string(k, ".non-lite.frame.jls")

metaframe_path(bb::BlobBatch) = joinpath(dirpath(bb), metaframe_name())
liteframe_path(bb::BlobBatch, k::String) = joinpath(dirpath(bb), liteframe_name(k))
nonliteframe_path(bb::BlobBatch, k::String) = joinpath(dirpath(bb), nonliteframe_name(k))

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
_lite_frames(bb::BlobBatch) = get!(OrderedDict{String, OrderedDict}, bb.frames, "lites")
_nonlite_frames(bb::BlobBatch) = get!(OrderedDict{String, OrderedDict}, bb.frames, "non-lites")

_lite_group(bb::BlobBatch, g::String) = get!(OrderedDict{String, Vector}, _lite_frames(bb), g)

# ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# function _has_ramframe(bb::BlobBatch, key)
#     # reserved
#     key == "temp" && return haskey(bb.frames, "temp")
#     key == "meta" && return haskey(bb.frames, "meta")
#     # lite/non-lite level
#     haskey(_lite_frames(bb), key) && return true
#     haskey(_nonlite_frames(bb), key) && return true
#     return false
# end

# function _has_diskframe(bb::BlobBatch, key)
#     # reserved
#     key == "temp" && return false
#     key == "meta" && return isfile(metaframe_path(bb))
#     # lite level
#     isfile(liteframe_path(bb, key)) && return true
#     # non-lite level
#     isfile(nonliteframe_path(bb, key)) && return true
#     return false
# end

# # --------------------------------------------------------
# # check ram, disk later
# function hasframe(bb::BlobBatch, key)
#     _has_ramframe(bb, key) && return true
#     _has_diskframe(bb, key) && return true
#     return false
# end

# ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# # getframe
# _temp_frame!(bb::BlobBatch) = get!(() -> OrderedDict{String, Any}(), bb.frames, "temp")
# function _meta_frame!(bb::BlobBatch) 
#     # check ram and return if true
#     _has_ramframe(bb, "meta") && return bb.frames["meta"]
#     # if missing in file, create in ram and return
#     _has_diskframe(bb, "meta") || return get!(() -> OrderedDict{String, Any}(), bb.frames, "temp")
#     # if in file, load and return
#     _meta = deserialize(metaframe_path(bb))
#     bb.frames["meta"] = _meta
#     return _meta
# end

# function _lite_frame!(bb::BlobBatch, key)
#     # check ram and return if true
#     _has_ramframe(bb, key) && return _lite_frames(bb)[key]
#     # if missing in file, return nothing
#     _has_diskframe(bb, key) || nothing
#     # if in file, load and return
#     _lite = deserialize(liteframe_path(bb, key))
#     _lite_frames(bb)[key] = _lite
#     return _lite
# end

# function _full_frame!(bb::BlobBatch, key)
#     # check ram and return if true
#     _has_ramframe(bb, key) && return _lite_frames(bb)[key]
#     # if missing in file, return nothing
#     _has_diskframe(bb, key) || nothing
#     # if in file, load and return
#     _lite = deserialize(liteframe_path(bb, key))
#     bb.frames[key] = _lite
#     return _lite
# end


# function getframe(bb::BlobBatch, key::String)
#     # temp (RAM only)
#     key == "temp" && return _temp_frame!(bb)
        
#     # meta
#     if key == "meta" && return _meta_frame!(bb)
    


#     # frame groups
#     if !hasframe(bb, key) # check both ram and disk
#         # error
#         __frame_notfound_err(bb, key)
#     end
#     if !isframeloaded(bb, key) # load if needed
#         bb.frames[key] = deserialize(framefile(bb, key))
#     end
#     return getindex(bb.frames, key)
# end

# import Base.getindex
# function Base.getindex(bb::BlobBatch, key) 
#     # temp
#     key == "temp" && return get!(() -> OrderedDict{String, Any}(), bb.frames, "temp")
    
#     # meta
#     # TODO: handle meta on disk
#     if key == "meta" 
#         haskey(bb.frames, key) && return bb.frames["meta"]
#         return get!(() -> OrderedDict{String, Any}(), bb.frames, "meta")
#     end

#     getframe(bb, key)
# end

