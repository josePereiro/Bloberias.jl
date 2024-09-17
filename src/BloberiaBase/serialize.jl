## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# TODO: make an interface for this so more routines can be added
function onserialize!(B::Bloberia, args...)
    _ondemand_loadmeta!(B)
    B.meta["serialization.time"] = time()
    return nothing
end

# --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
function _serialize_meta(B::Bloberia)
    path = meta_framepath(B)
    _serialize(path, B.meta)
end

function _serialize_rablob(B::Bloberia)
    path = rablob_framepath(B, B.rablob_id)
    _mkpath(path)
    _serialize(path, B.rablob)
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
import Serialization.serialize
function Serialization.serialize(B::Bloberia; ignoreempty = true)

    dir = B.root
    isempty(dir) && return # noop
    mkpath(dir)

    # callback
    onserialize!(B)

    # meta
    ignore = ignoreempty && isempty(B.meta)
    ignore || _serialize_meta(B)
    
    # rablobs
    ignore = ignoreempty && isempty(B.rablob)
    ignore || _serialize_rablob(B)

    return B
end

# ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# import Serialization.serialize
# function Serialization.serialize(bb::BlobBatch, frame::AbstractString; ignoreempty = true)
    
#     ignore = isempty(bb)
#     ignore = ignore && ignoreempty 
#     ignore && return bb
    
#     onserialize!(bb, frame)

#     dir = batchpath(bb)
#     isempty(dir) && return # noop
#     mkpath(dir)
    
#     # meta
#     if frame == "meta"
#         ignore = isempty(bb.meta)
#         ignore = ignore && ignoreempty 
#         ignore || _serialize_meta(bb)
#         return
#     end
    
#     # uuids
#     if frame == "uuids"
#         ignore = isempty(bb.uuids)
#         ignore = ignore && ignoreempty 
#         ignore || _serialize_uuids(bb)
#     end

#     # frames
#     ignore = isempty(bb.frames) | isempty(bb.frames[frame])
#     ignore = ignore && ignoreempty 
#     ignore || _serialize_datframe(bb, frame)

#     return bb
# end
