## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
function _bb_show_file_sortby(ph)
    name = basename(ph)
    name == "meta.jls" && return "."
    name == "vuuids.jls" && return ".."
    return name
end

function _show_vframes(io::IO, bb::BlobBatch)
    isempty(bb.vframes) && return
    print(io, "\nRam vframes: ")
    for (frame, _bb_frame) in bb.vframes
        isempty(_bb_frame) && continue
        kT_pairs = Set()
        for (_, _b_frame) in _bb_frame
            for (key, val) in _b_frame
                push!(kT_pairs, string(key) => typeof(val))
            end
        end
        print(io, "\n \"", frame, "\" ")
        _kv_print_type(io, kT_pairs; _typeof = identity)
    end
end

function _show_dframes(io::IO, bb::BlobBatch)
    isempty(bb.dframes) && return
    print(io, "\nRam dframes: ")
    for (frame, _bb_frame) in bb.dframes
        isempty(_bb_frame) && continue
        kT_pairs = Set()
        for (key, val) in _bb_frame
            push!(kT_pairs, string(key) => typeof(val))
        end
        print(io, "\n \"", frame, "\" ")
        _kv_print_type(io, kT_pairs; _typeof = identity)
    end
end

function _show_disk_files(io::IO, bb::BlobBatch)
    _bb_filesize = 0.0
    print(io, "\nDisk files: ")
    b_files = isdir(bb) ? readdir(batchpath(bb); join = true) : []
    sort!(b_files; by = _bb_show_file_sortby)
    for path in b_files
        # endswith(path, hint) || continue
        _filesize = filesize(path)
        val, unit = _canonical_bytes(_filesize)
        print(io, "\n  \"", basename(path), "\" ")
        print(io, "[")
        printstyled(io, string(round(val; digits = 3), " ", unit);
            color = :blue
        )
        print(io, "]")
        _bb_filesize += _filesize
    end
    val, unit = _canonical_bytes(_bb_filesize)
    print(io, "\ndisk usage: ")
    printstyled(io, string(round(val; digits = 3), " ", unit);
        color = :blue
    )
end

import Base.show
function Base.show(io::IO, bb::BlobBatch)
    print(io, "BlobBatch(", repr(bb.id), ")")
    hasfilesys(bb) || return
    _pretty_print_pairs(io, 
        "\n filesys", 
        string("@./", basename(batchpath(bb)))
    )
    _pretty_print_pairs(io, 
        "\n vblob(s)", vblobcount(bb)
    )
    # vframes
    _show_vframes(io, bb)

    # dframes
    _show_dframes(io, bb)

    # disk
    _show_disk_files(io, bb)

    nothing

end