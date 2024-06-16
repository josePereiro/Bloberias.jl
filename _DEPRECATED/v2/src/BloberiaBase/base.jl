## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
Bloberia(root) = Bloberia(root, Ref{Blob}(), Ref{BlobBatch}(), OrderedDict(), Dict())
Bloberia() = Bloberia("")

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# stageblob
function stageblob(b::Bloberia) 
    isassigned(b.blob) && return b.blob[]
    b.blob[] = Blob()
    return b.blob[]
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# blobgroup

blobgroup(b::Bloberia, args...) = blobgroup(stageblob(b), args...)
blobgroup!(b::Bloberia, args...) = blobgroup!(stageblob(b), args...)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# getindex
import Base.getindex
Base.getindex(b::Bloberia, args...) = Base.getindex(stageblob(b), args...)

# setindex!
import Base.setindex!
Base.setindex!(b::Bloberia, args...) = Base.setindex!(stageblob(b), args...)

# merge!
import Base.merge!
Base.merge!(b::Bloberia, args...) = Base.merge!(stageblob(b), args...)

# emptyblob!
emptyblob!(b::Bloberia) = emptyblob!(stageblob(b))
emptygroup!(b::Bloberia) = emptygroup!(stageblob(b))

