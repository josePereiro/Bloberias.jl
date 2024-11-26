rablobpath(rb::raBlob) = joinpath(rablobs_dir(rb.B), rb.id)

_rab_meta_framepath(root::String) = joinpath(root, "meta.jls")
meta_framepath(bb::raBlob) = _rab_meta_framepath(rablobpath(bb))

_rab_dat_framepath(root::String, frame) = joinpath(root, string(frame, ".frame.jls"))
dat_framepath(bb::raBlob, frame) = _rab_dat_framepath(rablobpath(bb), frame)


## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Base

import Base.rm
Base.rm(rb::raBlob; force = true) = Base.rm(rablobpath(rb); force, recursive = true)

import Base.isdir
Base.isdir(rb::raBlob) = Base.isdir(rablobpath(rb))