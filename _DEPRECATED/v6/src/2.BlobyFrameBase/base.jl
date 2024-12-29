## --.--. .- . .- -- - ---- .- - .- .-.- .- -.-. 
# Base
import Base.show
function Base.show(io::IO, fr::BlobyFrame)
    println(io, "BlobyFrame{", repr(_frame_fT(fr)), ", ", _frame_dT(fr), "}")
    println(io, "   id:   ", fr.id)
    print(io,   "   dat:  "); 
    show(io, fr.dat)
end

## --.--. .- . .- -- - ---- .- - .- .-.- .- -.-. 
# assert frame type

_frame_fT(::BlobyFrame{fT, dT}) where fT where dT = fT
function _any_fT(fT0::Symbol, fTs::Symbol...)
    for fT in fTs
        fT === :IGNORE && return true
        fT0 === fT && return true
    end
    return false
end
_any_fT(fr::BlobyFrame, fTs...) = 
    _any_fT(_frame_fT(fr), fTs...)
function _assert_fT(fT0::Symbol, fTs...)
    _any_fT(fT0, fTs...) && return
    error("invalid frame fT, ", fT0)
end
_assert_fT(fr::BlobyFrame, fTs...) = 
    _assert_fT(_frame_fT(fr), fTs...)

_frame_dT(::BlobyFrame{fT, dT}) where fT where dT = dT
function _any_dT(fr::BlobyFrame, dTs...)
    for dT in dTs
        _frame_dT(fr) === dT && return true
    end
    return false
end
function _assert_dT(fr::BlobyFrame, dTs...)
    _any_dT(fr, dTs...) && return
    error("invalid frame dT, ", _frame_dT)
end

# get blob data on frame
_frame_dat(bfr::BlobyFrame{fT, dT}) where fT where dT = bfr.dat::dT
_frame_dat(x) = x # base
_frame_dat(ab::AbstractBlob, bfr::BlobyFrame) = error("Missing implementation")
_frame_dat(ab::AbstractBlob, bfr) = _frame_dat(bfr)

## --.--. .- . .- -- - ---- .- - .- .-.- .- -.-. 
# frame interface

frame_path(root::String, id::String) = 
    joinpath(root, string(id, ".frame.jls"))

## --.--. .- . .- -- - ---- .- - .- .-.- .- -.-. 
# Base

import Base.isempty
Base.isempty(bf::BlobyFrame) = isempty(bf.dat)

## --.--. .- . .- -- - ---- .- - .- .-.- .- -.-. 
# errorless
function _serialize_frame(path::String, frame::BlobyFrame)
    _mkpath(path)
    serialize(path, 
        (;
            dat = frame.dat, 
            id = frame.id, 
            fT = _frame_fT(frame), 
            dT = _frame_dT(frame), 
        )
    )
end

function _deserialize_frame(fpath::String)
    ft = deserialize(fpath)
    return BlobyFrame{ft.fT, ft.dT}(ft.id, ft.dat)
end

import Base.merge!
function Base.merge!(f0::BlobyFrame, f1::BlobyFrame)
    Base.merge!(_frame_dat(f0), _frame_dat(f1))
    return f0
end