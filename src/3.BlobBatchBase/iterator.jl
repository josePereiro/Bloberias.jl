# ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# function eachblob(bb::BlobBatch)
#     return Channel{vBlob}(0) do _ch
#         ondemand_loadvuuids!(bb)
#         for uuid in bb.vuuids
#             b = vBlob(bb, uuid) # I do not need to check if blob exist
#             put!(_ch, b)
#         end
#     end
# end

# ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# # Iterator
# function _bb_iterate_next(ch::Channel, ch_next)
#     isnothing(ch_next) && return nothing
#     item, ch_state = ch_next
#     bb_state = (ch, ch_state)
#     return (item, bb_state)
# end

# import Base.iterate
# function Base.iterate(bb::BlobBatch)
#     ch = eachblob(bb)
#     ch_next = iterate(ch)
#     return _bb_iterate_next(ch, ch_next)
# end

# function Base.iterate(::BlobBatch, bb_state) 
#     isnothing(bb_state) && return nothing
#     ch, ch_state = bb_state
#     ch_next = iterate(ch, ch_state)
#     return _bb_iterate_next(ch, ch_next)
# end

# import Base.length
# Base.length(bb::BlobBatch) = vblobcount(bb)

