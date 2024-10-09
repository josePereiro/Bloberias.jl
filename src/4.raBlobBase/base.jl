## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Constructor
raBlob(B::Bloberia, id) = raBlob(B, id, OrderedDict())
raBlob(B::Bloberia) = raBlob(B, BLOBERIA_DEFAULT_RABLOB_ID, OrderedDict())

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
import Base.show
function Base.show(io::IO, b::raBlob)
    print(io, "raBlob(", repr(b.id), ")")
    # for (frame, _bb_frame) in b.batch.frames
    #     haskey(_bb_frame, b.uuid) || continue
    #     _b_frame = _bb_frame[b.uuid]
    #     isempty(_b_frame) && continue
    #     println(io)
    #     print(io, " \"", frame, "\" ")
    #     _kv_print_type(io, _b_frame; _typeof = typeof)
    # end
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# getindex
function _rablob_dict!(b::raBlob)::OrderedDict
    _ondemand_loadrablob!(b)
    return b.data
end

import Base.getindex
Base.getindex(b::raBlob, key) = _rablob_dict!(b)[key]
Base.getindex(b::raBlob, T::Type, key) = _rablob_dict!(b)[key]::T

# setindex
Base.setindex!(b::raBlob, value, key) = 
    setindex!(_rablob_dict!(b), value, key)

import Base.get
Base.get(b::raBlob, key, default) = 
    Base.get(_rablob_dict!(b), key, default)
Base.get(f::Function, b::raBlob, key) = 
    Base.get(f, _rablob_dict!(b), key)

import Base.get!
Base.get!(b::raBlob, key, default) = 
    Base.get!(_rablob_dict!(b), key, default)
Base.get!(f::Function, b::raBlob, key) = 
    Base.get!(f, _rablob_dict!(b), key)

import Base.keys
Base.keys(b::raBlob) = keys(_rablob_dict!(b))

import Base.values
Base.values(b::raBlob) = keys(_rablob_dict!(b))

import Base.haskey
Base.haskey(b::raBlob, key) = keys(_rablob_dict!(b), key)

# import Base.get
# function Base.get(dflt::Function, b::raBlob, frame::AbstractString, key)
#     # frame == "temp" && return get(dflt, b.temp, key)
#     _ondemand_loaddat!(b.batch, frame) # loaded on batch
#     haskey(b.batch.frames, frame) || return dflt()
#     _bb_frame = b.batch.frames[frame]
#     haskey(_bb_frame, b.uuid) || return dflt()
#     _b_frame = _bb_frame[b.uuid]
#     return get(dflt, _b_frame, key)
# end
# Base.get(dflt::Function, b::raBlob, key) = get(dflt, b, BLOBBATCH_DEFAULT_FRAME_NAME, key)
# Base.get(b::raBlob, key, frame::AbstractString, dflt) = get(()-> dflt, b, frame, key)
# Base.get(b::raBlob, key, dflt) = get(b, BLOBBATCH_DEFAULT_FRAME_NAME, key, dflt)

# import Base.get!
# function Base.get!(dflt::Function, b::raBlob, frame::AbstractString, key)
#     # frame == "temp" && return get!(dflt, b.temp, key)
#     _ondemand_loaddat!(b.batch, frame) # loaded on batch
#     _bb_frame = get!(OrderedDict, b.batch.frames, frame)
#     _b_frame = get!(OrderedDict, _bb_frame, b.uuid)
#     return get!(dflt, _b_frame, key)
# end
# Base.get!(dflt::Function, b::raBlob, key) = get!(dflt, b, BLOBBATCH_DEFAULT_FRAME_NAME, key)
# Base.get!(b::raBlob, frame::AbstractString, key, dflt) = get!(()-> dflt, b, frame, key)
# Base.get!(b::raBlob, key, dflt) = get!(b, BLOBBATCH_DEFAULT_FRAME_NAME, key, dflt)

# import Base.haskey
# function Base.haskey(b::raBlob, frame::AbstractString, key)
#     # frame == "temp" && return haskey(b.temp, key)
#     _ondemand_loaddat!(b.batch, frame) # loaded on batch
#     haskey(b.batch.frames, frame) || return false
#     _bb_frame = b.batch.frames[frame]
#     haskey(_bb_frame, b.uuid) || return false
#     _b_frame = _bb_frame[b.uuid]
#     return haskey(_b_frame, key)
# end
# Base.haskey(b::raBlob, key) = haskey(b, BLOBBATCH_DEFAULT_FRAME_NAME, key)

# ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# # merge!
# import Base.merge!
# function Base.merge!(b::raBlob, frame::String, dat; force = true, prefix = "")
#     _b_frame = getframe!(b, frame)
#     for (k, v) in dat
#         k = string(prefix, k)
#         # check overwrite
#         !force && haskey(_b_frame, k) && error("Overwrite is not allowed, use `force=true`")
#         _b_frame[k] = v
#     end
#     return b
# end
# Base.merge!(b::raBlob, dat; force = true, prefix = "") = 
#     merge!(b, BLOBBATCH_DEFAULT_FRAME_NAME, dat; force, prefix)