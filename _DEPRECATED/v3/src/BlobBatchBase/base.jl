## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# Constructor
const BLOBBATCH_DEFAULT_GROUP = "0"
BlobBatch(B::Bloberia, group::AbstractString, uuid) = BlobBatch(B, group, uuid,
    OrderedDict(), Int128[], OrderedDict(), OrderedDict(), 
    OrderedDict()
)
BlobBatch(B::Bloberia, group::AbstractString) = BlobBatch(B, group, uuid_str())
BlobBatch(B::Bloberia) = BlobBatch(B, BLOBBATCH_DEFAULT_GROUP, uuid_str())

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
blob(bb::BlobBatch) = Blob(bb)
function blob(bb::BlobBatch, uuid::Int)
    # TODO
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# push! b into bb, create new frames if necessary
function _commmit!(bb::BlobBatch, b::Blob)
    _ondemand_loaduuids!(bb)
    push!(bb.uuids, b.uuid)
    _ondemand_loadlite!(bb)
    push!(bb.lite, b.uuid => b.lite)
    for (gkey, b_group) in b.nonlite
        _ondemand_loadnonlite!(bb, gkey)
        bb_group = get!(OrderedDict, bb.nonlite, gkey)
        push!(bb_group, b.uuid => b_group)
    end
    return bb
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
function up_metadata!(bb::BlobBatch)
    meta = bb.meta
    if !isempty(bb.uuids)
        meta["blobs.count"] = length(bb.uuids)
    end
    meta["serialization.time"] = time()
    return nothing
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# getframe
function _get_level1(bb::BlobBatch, k::String)
    k == "temp" && return bb.temp
    if k == "meta"
        _ondemand_loadmeta!(bb)
        return bb.meta
    end
    if k == "uuids"
        _ondemand_loaduuids!(bb)
        return bb.uuids
    end
    if k == "lite"
        _ondemand_loadlite!(b)
        return bb.lite
    end
    return nothing
end

function getframe(bb::BlobBatch, k::String)
    ret = _get_level1(bb, k)
    isnothing(ret) || return ret
    _ondemand_loadnonlite!(bb, k)
    return bb.nonlite[k]
end

function getframe(f::Fucntion, bb::BlobBatch, k::String)
    ret = _get_level1(bb, k)
    isnothing(ret) || return ret
    _ondemand_loadnonlite!(bb, k)
    return get(f, bb.nonlite, k)
end

function getframe(bb::BlobBatch, k::String, dflt)
    ret = _get_level1(bb, k)
    isnothing(ret) || return ret
    _ondemand_loadnonlite!(bb, k)
    return get(bb.nonlite, k, dflt)
end