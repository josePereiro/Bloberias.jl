## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# meta interface
function _meta(bb::BlobBatch)::OrderedDict
    _ondemand_loadmeta!(bb)
    return bb.meta
end

