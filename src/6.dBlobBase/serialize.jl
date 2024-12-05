## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
serialize!(db::dBlob; kwargs...) =
    serialize_dframe!(db.bb; kwargs...)