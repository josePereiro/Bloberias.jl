## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
const BLOBERIA_DEFAULT_BATCH_GROUP = "0"
const BLOBERIA_DEFAULT_FRAME_NAME = "0"

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Constructor
Bloberia(root) = Bloberia(root, OrderedDict(), OrderedDict())
Bloberia() = Bloberia("")

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# filesys
function _hasfilesys(B::Bloberia)
    isempty(B.root) && return false
    return true
end

import Base.rm
Base.rm(B::Bloberia; force = true, recursive = true) = 
    _hasfilesys(B) && rm(B.root; force, recursive)

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Use, uuids
# function blobcount(B::Bloberia)
#     count = 0
#     for bb in bbs
#     end
# end