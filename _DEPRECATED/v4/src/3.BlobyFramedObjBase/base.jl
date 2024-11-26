# getframe 
# get frame interface b[["bla"]]
import Base.getindex
function Base.getindex(fo::BlobyFramedObj, framev::Vector) 
    isempty(framev) && return getframe(fo) # default frame
    @assert length(framev) == 1
    return getframe(fo, first(framev)) # custom frame
end

