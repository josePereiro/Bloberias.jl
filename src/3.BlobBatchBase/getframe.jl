getvframe(bb::BlobBatch) = bb.vframes
function getvframe(bb::BlobBatch, framekey::AbstractString)
    ondemand_loadvframe!(bb, framekey)
    return getindex(bb.vframes, framekey)
end
function getvframe!(bb::BlobBatch, framekey::AbstractString)
    ondemand_loadvframe!(bb, framekey)
    return get!(OrderedDict, bb.vframes, framekey)
end

getdframe(bb::BlobBatch) = bb.dframes
function getdframe(bb::BlobBatch, framekey::AbstractString)
    ondemand_loaddframe!(bb, framekey)
    return getindex(bb.dframes, framekey)
end
function getdframe!(bb::BlobBatch, framekey::AbstractString)
    ondemand_loaddframe!(bb, framekey)
    return get!(OrderedDict, bb.dframes, framekey)
end

# ## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
# # hasframe
# function hasframe_ram(bb::BlobBatch, frame)
#     # check ram
#     frame == "temp" && return true
#     frame == "meta" && return true
#     haskey(bb.frames, frame) && return true
#     return false
# end

# function hasframe_disk(bb::BlobBatch, frame)
#     frame == "temp" && return false
#     frame == "meta" && return isfile(meta_jlspath(bb))
#     isfile(vframe_jlspath(bb, frame)) && return true
#     return false
# end

# function hasframe(bb::BlobBatch, frame)
#     hasframe_ram(bb, frame) && return true
#     hasframe_disk(bb, frame) && return true
#     return false
# end