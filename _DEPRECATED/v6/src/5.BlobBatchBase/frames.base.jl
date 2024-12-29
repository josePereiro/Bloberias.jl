
## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# frame data interface

# getframe!(bb..) can only creates frames from 
# which setindex! can act...
function getframe!(bb::BlobBatch, id::String)
    fr = _depot_frame!(bb, :IGNORE, id) do
        # if missing
        id == META_FRAMEID && return BlobyFrame{META_FRAME_TYPE, DICT_DEPOT_TYPE}(id, DICT_DEPOT_TYPE())

        id == bUUIDS_FRAMEID && return BlobyFrame{bUUIDS_FRAME_TYPE, UUIDS_DEPOT_TYPE}(id, UUIDS_DEPOT_TYPE())

        return BlobyFrame{bb_bbFRAME_FRAME_TYPE, DICT_DEPOT_TYPE}(id, DICT_DEPOT_TYPE())
    end
    return _frame_dat(bb, fr) 
end

## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# frames accessors
getmeta(bb::BlobBatch) = getframe!(bb, META_FRAMEID)
function getmeta!(bb::BlobBatch)
    fr = _depot_frame!(bb, META_FRAME_TYPE, META_FRAMEID) do
        # if missing
        return BlobyFrame{META_FRAME_TYPE, DICT_DEPOT_TYPE}(META_FRAMEID, DICT_DEPOT_TYPE())
    end
    return _frame_dat(bb, fr) 
end

getbuuids(bb::BlobBatch) = getframe(bb, bUUIDS_FRAMEID)
function getbuuids!(bb::BlobBatch)
    fr = _depot_frame!(bb, bUUIDS_FRAME_TYPE, bUUIDS_FRAMEID) do
        # if missing
        return BlobyFrame{bUUIDS_FRAME_TYPE, UUIDS_DEPOT_TYPE}(bUUIDS_FRAMEID, UUIDS_DEPOT_TYPE())
    end
    return _frame_dat(bb, fr) 
end

function _getbframe!(bb::BlobBatch, id)
    return _depot_frame!(bb, bb_bFRAME_FRAME_TYPE, id) do
        # if missing
        return BlobyFrame{bb_bFRAME_FRAME_TYPE, VECDICT_DEPOT_TYPE}(id, VECDICT_DEPOT_TYPE())
    end
end

# ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 

import Base.setindex!
function Base.setindex!(bb::BlobBatch, val, frameid::String, key::String) 
    fr = getframe!(bb, frameid)
    setindex!(fr, val, key)
end

import Base.get
function Base.get(dflt::Function, bb::BlobBatch, frameid::String, key::String)
    hasframe(bb, frameid) || return dflt()
    fr = getframe(bb, frameid)
    return get(dflt, fr, key)
end

import Base.get!
function Base.get!(dflt::Function, bb::BlobBatch, frameid::String, key::String)
    fr = getframe!(bb, frameid)
    return get!(dflt, fr, key)
end

import Base.empty!
Base.empty!(bb::BlobBatch) = empty!(bb.frames)
Base.empty!(bb::BlobBatch, id::String) = empty!(bb.frames[id])
import Base.isempty
Base.isempty(bb::BlobBatch) = isempty(bb.frames)
