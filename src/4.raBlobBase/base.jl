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
# getindex
import Base.getindex
Base.getindex(b::raBlob, frame::AbstractString, key) = 
    getindex(getframe(b, frame), key) # custom frame
Base.getindex(b::raBlob, T::Type, frame::AbstractString, key) = 
    getindex(getframe(b, frame), key)::T # custom frame
Base.getindex(b::raBlob, key) = 
    getindex(getframe(b), key) # default frame
Base.getindex(b::raBlob, T::Type, key) = 
    getindex(getframe(b), key)::T # default frame

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# setindex
function Base.setindex!(b::raBlob, value, frame::AbstractString, key)
    _b_frame = getframe!(b, frame) # add frame if required
    return setindex!(_b_frame, value, key)
end
Base.setindex!(b::raBlob, value, key) = 
    setindex!(b, value, BLOBBATCH_DEFAULT_FRAME_NAME, key)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 

# import Base.get
Base.get(b::raBlob, frame::AbstractString, key, default) = 
    Base.get(getframe(b, frame), key, default)
Base.get(f::Function, b::raBlob, frame::AbstractString, key) = 
    Base.get(f, getframe(b, frame), key)
Base.get!(b::raBlob, frame::AbstractString, key, default) = 
    Base.get!(getframe!(b, frame), key, default)
Base.get!(f::Function, b::raBlob, frame::AbstractString, key) = 
    Base.get!(f, getframe!(b, frame), key)

# default
Base.get(b::raBlob, key, default) = Base.get(getframe(b), key, default)
Base.get(f::Function, b::raBlob, key) = Base.get(f, getframe(b), key)
Base.get!(b::raBlob, key, default) = Base.get!(getframe!(b), key, default)
Base.get!(f::Function, b::raBlob, key) = Base.get!(f, getframe!(b), key)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.-
# :set! :get :get! :dry 
# all in ram
function withblob!(f::Function, rb::raBlob, mode::Symbol, frame, key::String)
    if mode == :set!
        return setindex!(rb, f(), frame, key)
    end
    if mode == :get
        return get(f, rb, frame, key)
    end
    if mode == :get!
        return get!(f, rb, frame, key)
    end
    if mode == :dry
        return f()
    end
    error("Unknown mode, ", mode, ". see withblob! src")
end
withblob!(f::Function, rb::raBlob, mode::Symbol, key::String) = 
    withblob!(f, rb, mode, BLOBBATCH_DEFAULT_FRAME_NAME, key)

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