# Add Bloberias meta stuff
function force_loadmeta!(B::Bloberia)
    _frame_dat = _trydeserialize(meta_jlspath(B))
    isnothing(_frame_dat) && return nothing
    empty!(B.meta)
    merge!(B.meta, _frame_dat)
    return nothing
end

function ondemand_loadmeta!(B::Bloberia)
    isempty(B.meta) && force_loadmeta!(B)
    return nothing
end