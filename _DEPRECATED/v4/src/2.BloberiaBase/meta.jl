## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# meta interface
function _meta(B::Bloberia)::OrderedDict
    _ondemand_loadmeta!(B)
    return B.meta
end
