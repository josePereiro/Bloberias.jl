## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Constructor
Bloberia(root) = Bloberia(root, FRAMES_DEPOT_TYPE(), DICT_DEPOT_TYPE())

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# shallow copy 
import Base.copy
Base.copy(B::Bloberia) = Bloberia(B.root) 

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# BlobyObj interface

_blobyobj_root_I(B::Bloberia) = B.root

bloberia(B::Bloberia) = B
bloberiapath(B::Bloberia) = B.root
bloberiapath(bo::BlobyObj) = bloberiapath(bloberia(bo))
