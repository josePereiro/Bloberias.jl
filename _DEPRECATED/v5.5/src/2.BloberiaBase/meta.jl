## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# meta interface
function _meta(B::Bloberia)::OrderedDict
    ondemand_loadmeta!(B)
    return B.meta
end
