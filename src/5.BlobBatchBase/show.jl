## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
function _bb_show_file_sortby(ph)
    name = basename(ph)
    name == "meta.jls" && return "."
    name == "buuids.jls" && return ".."
    return name
end

function _show_kT_frames(push_kTpairs!, io::IO, ab::AbstractBlob, type, msg)
    depot = frames_depot(ab)
    isempty(depot) && return
    print(io, "\n\n$(msg): ")
    for (id, frame) in depot
        _frame_fT(frame) == type || continue
        isempty(frame.dat) && continue
        kT_pairs = Set()
        push_kTpairs!(kT_pairs, frame.dat)
        print(io, "\n \"", id, "\"")
        print(io, "\n   ")
        _kv_print_type(io, kT_pairs; _typeof = identity)
    end
end

_show_bframes(io::IO, bb::BlobBatch) =
    _show_kT_frames(io, bb, 
        bb_bFRAME_FRAME_TYPE, 
        "Ram bframes (max 100 blobs sampled)"
    ) do kT_pairs, _bb_frame
        _blob_count = 0
        for (_, _b_frame) in _bb_frame
            for (key, val) in _b_frame
                push!(kT_pairs, string(key) => typeof(val))
            end
            _blob_count += 1
            _blob_count > 100 && break
        end
    end

_show_bbframes(io::IO, bb::BlobBatch) =
    _show_kT_frames(io, bb, bb_bbFRAME_FRAME_TYPE, "Ram bbframes") do kT_pairs, _bb_frame
        for (key, val) in _bb_frame
            push!(kT_pairs, string(key) => typeof(val))
        end
    end


import Base.show
function Base.show(io::IO, bb::BlobBatch)
    print(io, "BlobBatch(", repr(bb.id), ")")
    _pretty_print_pairs(io, 
        "\n filesys", 
        string("@./", basename(batchpath(bb)))
    )
    _pretty_print_pairs(io, 
        "\n vblob(s)", blobcount(bb)
    )
    # bframes
    _show_bframes(io, bb)

    # bbframes
    _show_bbframes(io, bb)

    # disk
    _show_disk_files(io, batchpath(bb)) do path
        endswith(path, ".jls") || return false
        return true
    end

    nothing

end