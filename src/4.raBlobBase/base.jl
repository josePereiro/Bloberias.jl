## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Constructor
raBlob(B::Bloberia, id) = raBlob(B, id, OrderedDict(), OrderedDict(), OrderedDict())
raBlob(B::Bloberia) = raBlob(B, BLOBERIA_DEFAULT_RABLOB_ID)

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
import Base.getindex
Base.getindex(b::raBlob, frame::AbstractString, key) = getindex(getframe(b, frame), key) # custom frame
Base.getindex(b::raBlob, T::Type, frame::AbstractString, key) = getindex(getframe(b, frame), key)::T # custom frame
Base.getindex(b::raBlob, key) = getindex(getframe(b), key) # default frame
Base.getindex(b::raBlob, T::Type, key) = getindex(getframe(b), key)::T # default frame

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# setindex
# setindex
function Base.setindex!(b::raBlob, value, frame::AbstractString, key)
    _b_frame = getframe!(b, frame) # add frame if required
    return setindex!(_b_frame, value, key)
end
Base.setindex!(b::raBlob, value, key) = 
    setindex!(b, value, BLOBBATCH_DEFAULT_FRAME_NAME, key)

# import Base.get
# Base.get(b::raBlob, key, default) = 
#     Base.get(_rablob_dict!(b), key, default)
# Base.get(f::Function, b::raBlob, key) = 
#     Base.get(f, _rablob_dict!(b), key)

# import Base.get!
# Base.get!(b::raBlob, key, default) = 
#     Base.get!(_rablob_dict!(b), key, default)
# Base.get!(f::Function, b::raBlob, key) = 
#     Base.get!(f, _rablob_dict!(b), key)

# import Base.keys
# Base.keys(b::raBlob) = keys(_rablob_dict!(b))

# import Base.values
# Base.values(b::raBlob) = keys(_rablob_dict!(b))

# import Base.haskey
# Base.haskey(b::raBlob, key) = keys(_rablob_dict!(b), key)

# # isempty
# Base.isempty(bb::BlobBatch) = isempty(bb.frames)