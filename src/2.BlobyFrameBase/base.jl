## --.--. .- . .- -- - ---- .- - .- .-.- .- -.-. 
# Base
import Base.show
function Base.show(io::IO, fr::BlobyFrame)
    println(io, "BlobyFrame{", repr(_frame_fT(fr)), ", ", _frame_dT(fr), "}")
    println(io, "   id:   ", fr.id)
    println(io, "   path: ", fr.path)
    print(io,   "   dat:  "); show(io, fr.dat)
end

## --.--. .- . .- -- - ---- .- - .- .-.- .- -.-. 

_frame_fT(::BlobyFrame{fT, dT}) where fT where dT = fT
_frame_dT(::BlobyFrame{fT, dT}) where fT where dT = dT
_frame_path(root::String, id::String) = 
    joinpath(root, string(id, ".frame.jls"))

## --.--. .- . .- -- - ---- .- - .- .-.- .- -.-. 
# _getframe interface

# To Implement
frames_depot(bo::BlobyObj) = error("Too implement") # reimplement this if needed

frame_path(bo::BlobyObj, id) = _frame_path(_frames_root(bo), id)

## --.--. .- . .- -- - ---- .- - .- .-.- .- -.-. 
# Base

import Base.isempty
Base.isempty(bf::BlobyFrame) = isempty(bf.dat)

## --.--. .- . .- -- - ---- .- - .- .-.- .- -.-. 
# file sys
import Base.rm
Base.rm(bo::BlobyObj, id) =
    rm(frame_path(bo, id); force, recursive = true)

import Base.isfile
Base.isfile(bo::BlobyObj, id) = isfile(frame_path(bo, id))

