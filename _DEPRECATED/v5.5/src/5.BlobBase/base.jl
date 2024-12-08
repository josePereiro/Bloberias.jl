## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Constructor
# deafult is ok

# shallow copy 
import Base.copy
Base.copy(bt::Blob) = Blob(bt.bb, bb.uuid)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
blobbatch(b::Blob) = b.bb
bloberia(b::Blob) = bloberia(blobbatch(b))

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# lock
function _lock_obj_identity_hash(vb::Blob, h0)::UInt64
    h = _lock_obj_identity_hash(vb.bb, h0)
    h = hash(:Blob, h)
    h = hash(vb.uuid, h)
    return h
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# isempty
function Base.isempty(d::Blob) 
    for (_, framedat) in bb.bframes
        haskey(framedat, vb.uuid) && return false
    end
    return false
end
# Base.empty!(d::Blob) = empty!(d.bb.bbframes)

# ram only
import Base.empty!
function empty!(vb::Blob)
    bb = vb.bb
    for (_, framedat) in bb.bframes
        haskey(framedat, vb.uuid) || continue
        empty!(framedat[vb,uuid])
    end
end

# ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# import Base.show
# function Base.show(io::IO, b::Blob)
#     print(io, "Blob(", repr(b.uuid), ")")
#     for (frame, _bb_frame) in b.bb.bframes
#         haskey(_bb_frame, b.uuid) || continue
#         _b_frame = _bb_frame[b.uuid]
#         isempty(_b_frame) && continue
#         println(io)
#         print(io, " \"", frame, "\" ")
#         _kv_print_type(io, _b_frame; _typeof = typeof)
#     end
# end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# # setindex
# function Base.setindex!(b::Blob, value, frame::AbstractString, key)
#     _b_frame = getframe!(b, frame) # add frame if required
#     return setindex!(_b_frame, value, key)
# end
