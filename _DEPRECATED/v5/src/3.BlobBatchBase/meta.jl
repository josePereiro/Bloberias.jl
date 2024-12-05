## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# meta interface
function _meta(bb::BlobBatch)::OrderedDict
    ondemand_loadmeta!(bb)
    return bb.meta
end

