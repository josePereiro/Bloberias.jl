## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# frame data interface

function getframe!(B::Bloberia, id::String)
    _depot_frame!(B, :IGNORE, id) do
        # Check id
        id == META_FRAMEID || error("Bloberia only has a 'meta' frame, got: '$id'")
        return BlobyFrame{META_FRAME_TYPE, DICT_DEPOT_TYPE}(id, DICT_DEPOT_TYPE())
    end
    return getframe(B, id)
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# frames accessors
getmeta(B::Bloberia) = getframe!(B, META_FRAMEID)
function getmeta!(B::Bloberia)
    _depot_frame!(B, :IGNORE, META_FRAMEID) do
        # if missing
        return BlobyFrame{META_FRAME_TYPE, DICT_DEPOT_TYPE}(META_FRAMEID, DICT_DEPOT_TYPE())
    end
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 

import Base.setindex!
function Base.setindex!(B::Bloberia, val, frameid::String, key::String) 
    fr = getframe!(B, frameid)
    setindex!(fr, val, key)
end

import Base.get
function Base.get(dflt::Function, B::Bloberia, frameid::String, key::String)
    hasframe(B, frameid) || return dflt()
    fr = getframe(B, frameid)
    return get(dflt, fr, key)
end

import Base.get!
function Base.get!(dflt::Function, B::Bloberia, frameid::String, key::String)
    fr = getframe!(B, frameid)
    return get!(dflt, fr, key)
end

import Base.empty!
Base.empty!(B::Bloberia) = empty!(B.frames)
Base.empty!(B::Bloberia, id::String) = empty!(B.frames[id])
import Base.isempty
Base.isempty(B::Bloberia) = isempty(B.frames)


