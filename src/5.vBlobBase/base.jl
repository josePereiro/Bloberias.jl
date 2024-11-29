## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Constructor
# deafult is ok

# shallow copy 
import Base.copy
Base.copy(bt::vBlob) = vBlob(bt.bb, bb.uuid)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
blobbatch(b::vBlob) = b.bb
bloberia(b::vBlob) = bloberia(blobbatch(b))

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# lock
function _lock_obj_identity_hash(vb::vBlob, h0)::UInt64
    h = _lock_obj_identity_hash(vb.bb, h0)
    h = hash(:vBlob, h)
    h = hash(vb.uuid, h)
    return h
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# ram only
import Base.empty!
function empty!(vb::vBlob)
    bb = vb.bb
    for (_, framedat) in bb.vframes
        haskey(framedat, vb.uuid) || continue
        empty!(framedat[vb,uuid])
    end
end

# ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# import Base.show
# function Base.show(io::IO, b::vBlob)
#     print(io, "vBlob(", repr(b.uuid), ")")
#     for (frame, _bb_frame) in b.bb.vframes
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
# function Base.setindex!(b::vBlob, value, frame::AbstractString, key)
#     _b_frame = getframe!(b, frame) # add frame if required
#     return setindex!(_b_frame, value, key)
# end
