## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# BlobyObj interface

bloberia(b::iBlob) = bloberia(b.bb)
blobbatch(b::iBlob) = b.bb

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# lock interface
function _lock_obj_identity_hash(b::iBlob, h0 = UInt64(0))::UInt64
    h = _lock_obj_identity_hash(b.bb, h0)
    h = hash(:iBlob, h)
    h = hash(b.uuid, h)
    return h
end