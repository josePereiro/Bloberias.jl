## --.-.--..-- - -- - - - -- . . . .. -. - - -- - 
# hasframe

# check for frame in depot
function _hasframe_depot(ab::AbstractBlob, frameid::String) 
    depot = _frames_depot_I(ab)
    return haskey(depot, frameid) 
end

function _empty_depot!(ab::AbstractBlob)
    depot = _frames_depot_I(ab)
    empty!(depot)
end

## --.-.--..-- - -- - - - -- . . . .. -. - - -- - 
# frame depot accessors

# getindex on depot frame
function _getindex_depot_frame(ab::AbstractBlob, frameid::String)
    depot = _frames_depot_I(ab)
    return getindex(depot, frameid)
end

# setindex on depot frame
function _setindex_depot_frame!(ab::AbstractBlob, frameid::String, dat::Dict)
    depot = _frames_depot_I(ab)
    return setindex!(depot, dat, frameid)
end

# get on depot frame
function _get_depot_frame(dflt::Function, ab::AbstractBlob, frameid::String)
    depot = _frames_depot_I(ab)
    get(dflt, depot, frameid)
end

# get! on depot frame
function _get_depot_frame!(dflt::Function, ab::AbstractBlob, frameid::String)
    depot = _frames_depot_I(ab)
    get!(dflt, depot, frameid)
end

## --.-.--..-- - -- - - - -- . . . .. -. - - -- - 
# blob depot accessor

function _getindex_depot_blob(ab::AbstractBlob, frameid::String, key::String)
    _bdepot, bkey = _depotpath_I(ab, frameid) 
    _blob = getindex(_bdepot, bkey)
    return getindex(_blob, key)
end

function _setindex_depot_blob!(ab::AbstractBlob, frameid::String, key::String, val)
    _mk_depotpath_I!(ab, frameid)
    _bdepot, bkey = _depotpath_I(ab, frameid)
    _blob = getindex(_bdepot, bkey)::Dict
    return setindex!(_blob, val, key)
end

function _get_depot_blob(dflt::Function, ab::AbstractBlob, frameid::String, key::String)
    _has_depotpath_I(ab, frameid) || return dflt()
    _bdepot, bkey = _depotpath_I(ab, frameid) 
    _blob = getindex(_bdepot, bkey)::Dict
    return get(dflt, _blob, key)
end

function _get_depot_blob!(dflt::Function, ab::AbstractBlob, frameid::String, key::String)
    _mk_depotpath_I!(ab, frameid)
    _bdepot, bkey = _depotpath_I(ab, frameid)
    _blob = getindex(_bdepot, bkey)::Dict
    return get!(dflt, _blob, key)
end

