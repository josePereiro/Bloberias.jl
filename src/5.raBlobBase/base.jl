## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Constructor
raBlob(B::Bloberia, id) = raBlob(B, id, OrderedDict(), OrderedDict(), OrderedDict())
raBlob(B::Bloberia) = raBlob(B, BLOBERIA_DEFAULT_RABLOB_ID)
raBlob(rb::raBlob) = raBlob(rb.B, rb.id) # shadow copy

blob(rb::raBlob) = raBlob(rb)

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
# setindex
function Base.setindex!(b::raBlob, value, frame::AbstractString, key)
    _b_frame = getframe!(b, frame) # add frame if required
    return setindex!(_b_frame, value, key)
end

# import Base.keys
# Base.keys(b::raBlob) = keys(_rablob_dict!(b))

# import Base.values
# Base.values(b::raBlob) = keys(_rablob_dict!(b))

# import Base.haskey
# Base.haskey(b::raBlob, key) = keys(_rablob_dict!(b), key)

# isempty
Base.isempty(rb::raBlob) = isempty(rb.frames)

function Base.empty!(rb::raBlob) 
    empty!(rb.meta)
    empty!(rb.frames)
end