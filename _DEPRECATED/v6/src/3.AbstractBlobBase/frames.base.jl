## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Base dict interface
# All methods works with the dat field of frames

# public interface returns fr.dat

# get frame dat field
# NOTE: It must return the ram dat object of the frame
function getframe(ab::AbstractBlob, id::String, onmiss = _IGNORE)
    _onmissload_frame(ab, :IGNORE, id)
    fr = _depot_frame(ab, id, onmiss)
    return _frame_dat(ab, fr)
end
getframe(ab::AbstractBlob) = getframe(ab, dflt_frameid(ab))

# search ram/disk frame
# if missing creates and depot! a new one
# should returns a frame's dat
getframe!(ab::AbstractBlob, id::String) = error("Missing implementation")
getframe!(ab::AbstractBlob) = getframe!(ab, dflt_frameid(ab))


import Base.getindex
function Base.getindex(ab::AbstractBlob, frameid, key)
    frdat = getframe(ab, frameid)
    return Base.getindex(frdat, key)
end
Base.getindex(ab::AbstractBlob, key) = 
    Base.getindex(ab, dflt_frameid(ab), key)
Base.getindex(ab::AbstractBlob, frameid::Vector{String}) =
    getframe(ab, first(frameid))

Base.getindex(ab::AbstractBlob, ref::BlobyRef) = deref(ab, ref)

# index (order not controlled)
function Base.getindex(ab::AbstractBlob, i0::Int)
    for (i, el) in enumerate(ab)
        i0 == i && return el
    end
    error("Index our of bound!")
end


import Base.setindex!
Base.setindex!(ab::AbstractBlob, val, frameid::String, key::String) = 
    error("Missing implementation")
Base.setindex!(ab::AbstractBlob, val, key) = 
    setindex!(ab, val, dflt_frameid(ab), key)

Base.setindex!(ab::AbstractBlob, val, ref::BlobyRef) =
    setindex!(ab, val,
        ref.link["val.frame"]::String, 
        ref.link["val.key"]::String
    )

import Base.get
Base.get(dflt::Function, ab::AbstractBlob, frameid::String, key::String) =
    error("Missing implementation")
Base.get(dflt::Function, ab::AbstractBlob, key) = 
    get(dflt, ab, dflt_frameid(ab), key)
Base.get(ab::AbstractBlob, frameid, key, dflt) = get(() -> dflt, ab, frameid, key)
Base.get(ab::AbstractBlob, key, dflt) = get(() -> dflt, ab, dflt_frameid(ab), key)

import Base.get!
Base.get!(dflt::Function, ab::AbstractBlob, frameid, key) = 
    error("Missing implementation")
Base.get!(dflt::Function, ab::AbstractBlob, key::String) = 
    get!(dflt, ab, dflt_frameid(ab), key)
Base.get!(ab::AbstractBlob, frameid::String, key::String, dflt) = 
    get!(() -> dflt, ab, frameid, key)
Base.get!(ab::AbstractBlob, key::String, dflt) = 
    get!(() -> dflt, ab, dflt_frameid(ab), key)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Base
import Base.empty!
Base.empty!(ab::AbstractBlob) = error("Missing implementation")
Base.empty!(ab::AbstractBlob, id::String) = error("Missing implementation")
import Base.isempty
Base.isempty(ab::AbstractBlob) = error("Missing implementation")

empty_depot!(ab::AbstractBlob) = empty!(frames_depot(ab))

## ---- . .- ..- -.--.- . .-..--... - -- -. . .....
# get both ram and disk frame dat and allow you to have a do block
function withframes(f::Function, ab::AbstractBlob, id::String;
        lk = false, 
        lk_force = false
    )
    __dolock(ab, lk; force = lk_force) do
        return _withframes(ab, id) do _rfr, _dfr
            f(_frame_dat(ab, _rfr), _frame_dat(ab, _dfr))
        end
    end
end

# merge disk and ram version
# 'f' allow you to custom merge frames dat
# at the end, the ram data will be serialized back into disk...
function mergeframes!(f::Function, ab::AbstractBlob, id::String; 
        onerr  = _IGNORE, 
        lk = false, 
        lk_force = false
    )
    # TODO: Add flags to signal if the frames (_rfr, _dfr) are the same
    # or not... or if serialization must be aborted...
    __dolock(ab, lk; force = lk_force) do
        return _mergeframes!(ab, :IGNORE, id, onerr) do _rfr, _dfr
            if isnothing(_rfr) 
                getframe!(ab, id) # create if need it
                _rfr = _depot_frame(ab, id)
            end
            f(_frame_dat(ab, _rfr), _frame_dat(ab, _dfr))
            return _rfr
        end
    end
end

function mergeframes!(f::Function, ab::AbstractBlob; 
        onerr  = _IGNORE,
        lk = false, 
        lk_force = false
    )
    return mergeframes!(f, ab, dflt_frameid(ab); onerr, lk, lk_force)
end