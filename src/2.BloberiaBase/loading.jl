# Add Bloberias meta stuff
function _force_loadmeta!(B::Bloberia)
    _frame_dat = _trydeserialize(meta_framepath(B))
    isnothing(_frame_dat) && return nothing
    B.meta = _frame_dat
    return nothing
end

function _ondemand_loadmeta!(B::Bloberia)
    isempty(B.meta) && _force_loadmeta!(B)
    return nothing
end