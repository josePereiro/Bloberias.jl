function getframe(db::dBlob, frame::AbstractString)
    ondemand_loaddframe!(db.batch, frame)
    return getindex(db.batch.dframes, frame)
end

function getframe!(db::dBlob, frame::AbstractString)
    ondemand_loaddframe!(db.batch, frame) # loaded on batch
    _frame = get!(OrderedDict, db.batch.dframes, frame)
    return _frame
end

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
#     isfile(vframe_jlspath(db, frame)) && return true
#     return false
# end

# function hasframe(db::dBlob, frame)
#     hasframe_ram(db, frame) && return true
#     hasframe_disk(db, frame) && return true
#     return false
# end