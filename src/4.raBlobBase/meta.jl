## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# meta interface
function _meta(rb::raBlob)::OrderedDict
    _ondemand_loadmeta!(rb)
    return rb.meta
end

