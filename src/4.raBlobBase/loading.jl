## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# load rab (random access blobs) is the file exists

function _force_loadrablob!(rb::raBlob)
    _dat = _trydeserialize(rablob_framepath(rb))
    _dat = isnothing(_dat) ? OrderedDict() : _dat
    empty!(rb.data)
    merge!(rb.data, _dat)
    return nothing
end

function _ondemand_loadrablob!(rb::raBlob)
    isempty(rb.data) && _force_loadrablob!(rb)
    return nothing
end

