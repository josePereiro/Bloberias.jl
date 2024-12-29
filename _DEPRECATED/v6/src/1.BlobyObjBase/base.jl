## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# file sys interface

# To implement
# _blobypath

import Base.isdir
Base.isdir(bo::BlobyObj) = isdir(_blobypath(bo))

import Base.rm
Base.rm(bo::BlobyObj; force = true) = 
    rm(_blobypath(bo); force, recursive = true)
