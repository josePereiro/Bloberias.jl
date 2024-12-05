## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Constructor
# default is ok

import Base.copy
Base.copy(db::dBlob) = dBlob(db.bb)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# parents
bloberia(b::dBlob) = b.bb.B
blobbatch(b::dBlob) = b.bb

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# lock
function _lock_obj_identity_hash(db::dBlob, h0)::UInt64
    h = h0
    h = _lock_obj_identity_hash(db.bb, h0)
    h = hash(:dBlob, h)
    return h
end

# ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# import Base.show
# function Base.show(io::IO, b::dBlob)
#     print(io, "dBlob(", repr(b.id), ")")
#     # for (frame, _bb_frame) in b.bb.vframes
#     #     haskey(_bb_frame, b.uuid) || continue
#     #     _b_frame = _bb_frame[b.uuid]
#     #     isempty(_b_frame) && continue
#     #     println(io)
#     #     print(io, " \"", frame, "\" ")
#     #     _kv_print_type(io, _b_frame; _typeof = typeof)
#     # end
# end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 


# # import Base.keys
# # Base.keys(b::dBlob) = keys(_rablob_dict!(b))

# # import Base.values
# # Base.values(b::dBlob) = keys(_rablob_dict!(b))

# # import Base.haskey
# # Base.haskey(b::dBlob, key) = keys(_rablob_dict!(b), key)

# isempty
Base.isempty(db::dBlob) = isempty(db.bb.dframes)
Base.empty!(db::dBlob) = empty!(db.bb.dframes)