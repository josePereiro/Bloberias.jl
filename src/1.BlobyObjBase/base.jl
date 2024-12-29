## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# file sys interface

# To implement
_blobyobj_root_I(bo::BlobyObj, args...) = error("Missing Implementation")

import Base.isdir
Base.isdir(bo::BlobyObj) = isdir(_blobyobj_root_I(bo))

import Base.rm
Base.rm(bo::BlobyObj; force = true) = 
    rm(_blobyobj_root_I(bo); force, recursive = true)
