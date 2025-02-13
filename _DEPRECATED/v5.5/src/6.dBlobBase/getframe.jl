function getframe(db::dBlob, frame::AbstractString)
    ondemand_loadbbframe!(db.bb, frame)
    return getindex(db.bb.bbframes, frame)
end

function getframe!(db::dBlob, frame::AbstractString)
    ondemand_loadbbframe!(db.bb, frame) # loaded on batch
    _frame = get!(OrderedDict, db.bb.bbframes, frame)
    return _frame
end

getframes(db::dBlob) = db.bb.bbframes

# ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# # hasframe
# function hasframe_ram(db::dBlob, frame)
#     # check ram
#     frame == "temp" && return true
#     frame == "meta" && return true
#     haskey(db.frames, frame) && return true
#     return false
# end

# function hasframe_disk(db::dBlob, frame)
#     frame == "temp" && return false
#     frame == "meta" && isfile(meta_jlspath(db))
#     isfile(bframe_jlspath(db, frame)) && return true
#     return false
# end

# function hasframe(db::dBlob, frame)
#     hasframe_ram(db, frame) && return true
#     hasframe_disk(db, frame) && return true
#     return false
# end