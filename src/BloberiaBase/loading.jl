## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# load rab (random access blobs) is the file exists

function _force_loadmeta!(B::Bloberia)
    _frame_dat = _trydeserialize(meta_framepath(B))
    isnothing(_frame_dat) && return nothing
    B.meta = _frame_dat
    return nothing
end

function _force_loadrablob!(B::Bloberia, id)
    B.rablob_id = id
    _dat = _trydeserialize(rablob_framepath(B, id))
    if isnothing(_dat) 
        B.rablob = OrderedDict()
    else
        B.rablob = _dat
    end
    return nothing
end

function _ondemand_loadrablob!(B::Bloberia, id)
    B.rablob_id == id || _force_loadrablob!(B, id)
    return nothing
end

function _ondemand_loadmeta!(B::Bloberia)
    isempty(B.meta) && _force_loadmeta!(B)
    return nothing
end
