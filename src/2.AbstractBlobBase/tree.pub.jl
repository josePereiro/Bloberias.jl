## --.-.--..-- - -- - - - -- . . . .. -. - - -- - 

dflt_frameid(ab::AbstractBlob) = _deflt_frameid_I(ab)

## --.-.--..-- - -- - - - -- . . . .. -. - - -- - 
# get frames

function getframe(ab::AbstractBlob, frameid::String)
    _ondemand_try_load_frame!(ab, frameid)
    return _getindex_depot_frame(ab, frameid)
end

function getframe(dflt::Function, ab::AbstractBlob, frameid::String)
    _ondemand_try_load_frame!(ab, frameid)
    return _get_depot_frame(dflt, ab, frameid)
end

function getframe!(ab::AbstractBlob, frameid::String)
    _ondemand_try_loadmk_frame!(ab, frameid)
    return _getindex_depot_frame(ab, frameid)
end

## --.-.--..-- - -- - - - -- . . . .. -. - - -- - 
# hasframe

hasframe_depot(ab::AbstractBlob, frameid::String) =
    _hasframe_depot(ab, frameid)
hasframe_depot(ab::AbstractBlob) = 
    hasframe_depot(ab, _deflt_frameid_I(ab))

hasframe_disk(ab::AbstractBlob, frameid::String) =
    _hasframe_disk(ab, frameid)
hasframe_disk(ab::AbstractBlob) = 
    hasframe_disk(ab, _deflt_frameid_I(ab))

hasframe(ab::AbstractBlob, frameid::String) = 
    _hasframe_depotdisk(ab, frameid)
hasframe(ab::AbstractBlob) = 
    hasframe(ab, _deflt_frameid_I(ab))

    
## --.-.--..-- - -- - - - -- . . . .. -. - - -- - 
# haskey (work only on depot)

import Base.haskey
function Base.haskey(ab::AbstractBlob, frameid::String, key::String)
    _has_depotpath_I(ab, frameid) || return false
    _depot, _base = _depotpath_I(ab, frameid)
    haskey(_depot[_base], key) || return false
    return true
end
Base.haskey(ab::AbstractBlob, key::String) = 
    haskey(ab, _deflt_frameid_I(ab), key)

## --.-.--..-- - -- - - - -- . . . .. -. - - -- - 
# file interface

import Base.isdir
Base.isdir(ab::AbstractBlob) = isdir(_rootdir_I(ab))

import Base.rm
Base.rm(ab::AbstractBlob; force = true) = 
    rm(_rootdir_I(ab); force, recursive = true)

import Base.mkpath 
Base.mkpath(ab::AbstractBlob) = mkpath(_rootdir_I(ab))

import Base.filesize
Base.filesize(ab::AbstractBlob) = 
    _recursive_filesize(_rootdir_I(ab))

## --.-.--..-- - -- - - - -- . . . .. -. - - -- - 
# keys/values (work only on depot)

import Base.keys
function Base.keys(ab::AbstractBlob, path::String)
    _depot, _base = _depotpath_I(ab, path)
    return keys(_depot[_base])
end
Base.keys(ab::AbstractBlob) = 
    keys(ab, _deflt_frameid_I(ab))

import Base.values
function Base.values(ab::AbstractBlob, path::String)
    _depot, _base = _depotpath_I(ab, path)
    return values(_depot[_base])
end
Base.values(ab::AbstractBlob) = 
    values(ab, _deflt_frameid_I(ab))

## --.-.--..-- - -- - - - -- . . . .. -. - - -- - 
# delete! (work only on depot)
import Base.delete!
function Base.delete!(ab::AbstractBlob, path::String)
    _depot, _base = _depotpath_I(ab, path)
    return delete!(_depot, _base)
end

# delete! (work only on depot)
function delete_frame!(ab::AbstractBlob, frameid::String)
    _depot = _frames_depot_I(ab)
    delete!(_depot, frameid)
end
delete_frame!(ab::AbstractBlob) = 
    delete_frame!(ab, _deflt_frameid_I(ab))

## --.-.--..-- - -- - - - -- . . . .. -. - - -- - 
# empty! (work only on depot)
import Base.empty!
function Base.empty!(ab::AbstractBlob, path::String)
    _depot, _base = _depotpath_I(ab, path)
    return empty!(_depot, _base)
end

# empty_frame! (work only on depot)
function empty_frame!(ab::AbstractBlob, frameid::String)
    depot = _frames_depot_I(ab)
    empty!(depot[frameid])
end
empty_frame!(ab::AbstractBlob) = 
    empty_frame!(ab, _deflt_frameid_I(ab))


empty_depot!(ab::AbstractBlob) = _empty_depot!(ab)

## --.-.--..-- - -- - - - -- . . . .. -. - - -- - 
# getindex/setindex!

import Base.getindex
function Base.getindex(ab::AbstractBlob, frameid::String, key::String)
    _ondemand_try_load_frame!(ab, frameid)
    _getindex_depot_blob(ab, frameid, key)
end
function Base.getindex(ab::AbstractBlob, key::String)
    frameid = _deflt_frameid_I(ab)
    return getindex(ab, frameid, key)
end
function Base.getindex(ab::AbstractBlob, path::Vector)
    _depot, _base = _depotpath_I(ab, path...)
    return getindex(_depot, _base)
end

import Base.setindex!
function Base.setindex!(ab::AbstractBlob, val, frameid::String, key::String)
    _ondemand_try_loadmk_frame!(ab, frameid)
    _setindex_depot_blob!(ab, val, frameid, key)
end
function Base.setindex!(ab::AbstractBlob, val, key::String)
    frameid = _deflt_frameid_I(ab)
    return setindex!(ab, val, frameid, key)
end

import Base.get
function Base.get(dflt::Function, ab::AbstractBlob, frameid::String, key::String)
    _ondemand_try_load_frame!(ab, frameid)
    _get_depot_blob(dflt, ab, frameid, key)
end
function Base.get(ab::AbstractBlob, frameid::String, key::String, dflt)
    get(_constant(dflt), ab, frameid, key)
end
function Base.get(dflt::Function, ab::AbstractBlob, key::String)
    frameid = _deflt_frameid_I(ab)
    return get(dflt, ab, frameid, key)
end
function Base.get(ab::AbstractBlob, key::String, dflt)
    frameid = _deflt_frameid_I(ab)
    return get(_constant(dflt), ab, frameid, key)
end

import Base.get
function Base.get!(dflt::Function, ab::AbstractBlob, frameid::String, key::String)
    _ondemand_try_loadmk_frame!(ab, frameid)
    _get_depot_blob!(dflt, ab, frameid, key)
end
function Base.get!(ab::AbstractBlob, frameid::String, key::String, dflt)
    get!(_constant(dflt), ab, frameid, key)
end
function Base.get!(dflt::Function, ab::AbstractBlob, key::String)
    frameid = _deflt_frameid_I(ab)
    return get!(dflt, ab, frameid, key)
end
function Base.get!(ab::AbstractBlob, key::String, dflt)
    frameid = _deflt_frameid_I(ab)
    return get!(_constant(dflt), ab, frameid, key)
end

## --.-.--..-- - -- - - - -- . . . .. -. - - -- - 
# load
function ondemand_load!(ab::AbstractBlob, frameid::String)
    _ondemand_try_load_frame!(ab, frameid)
    return nothing
end
function ondemand_load!(ab::AbstractBlob)
    frameid = _deflt_frameid_I(ab)
    return ondemand_load!(ab, frameid)
end

function loadall_frames!(fil::Function, ab::AbstractBlob)
    _with_diskframes(ab) do frameid
        fil(frameid) === true && return :continue
        _load_frame!(ab, frameid)
    end
end
loadall_frames!(ab::AbstractBlob) =
    loadall_frames!(_constant(true), ab)

function ondemand_loadall!(fil::Function, ab::AbstractBlob)
    _with_diskframes(ab) do frameid
        fil(frameid) === true && return :continue
        _ondemand_load_frame!(ab, frameid)
    end
end
ondemand_loadall!(ab::AbstractBlob) = 
    ondemand_loadall!(_constant(true), ab)


## ---- . .- ..- -.--.- . .-..--... - -- -. . .....
# get both ram and disk versions and allow you to have a do block
# returns ram frame
function withblobs(dofun::Function, ab::AbstractBlob, frameid::String)
    ranblob = _depot_blob(ab, frameid, nothing)
    diskblob = _disk_blob(ab, frameid, nothing)
    return dofun(ranblob, diskblob)
end

function withblobs!(dofun::Function, ab::AbstractBlob, frameid::String)
    ranblob = _depot_blob!(ab, frameid)
    diskblob = _disk_blob(ab, frameid, nothing)
    return dofun(ranblob, diskblob)
end


# merge disk version with ram version
# 'f' allow you to custom merge frames dat
# at the end, the ram data will be serialized back into disk...
function mergeblobs!(mergef!::Function, ab::AbstractBlob, frameid::String;
        lk = false, 
        mk = true
    )
    __dolock(ab, lk) do
        ramblob = mk ? 
            _depot_blob!(ab, frameid) : 
            _depot_blob(ab, frameid, nothing)
        diskblob = _disk_blob(ab, frameid, nothing)
        mergef!(ramblob, diskblob) === :abort && return ramblob
        _serialize_depot_frame(ab, frameid)
        return ramblob
    end
end

function mergeblobs!(mergef!::Function, ab::AbstractBlob;
        lk = false, mk = true
    )
    frameid = _deflt_frameid_I(ab)
    mergeblobs!(mergef!, ab, frameid; lk, mk)
end

