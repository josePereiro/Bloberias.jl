## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
function _bb_show_file_sortby(ph)
    name = basename(ph)
    name == "meta.jls" && return "."
    name == "vuuids.jls" && return ".."
    return name
end

function _show_kT_frames(push_kTpairs!, io::IO, frames, msg)
    isempty(frames) && return
    # print(io, "\n\nRam vframes: ")
    print(io, "\n\n$(msg): ")
    for (frame, _bb_frame) in frames
        isempty(_bb_frame) && continue
        kT_pairs = Set()
        push_kTpairs!(kT_pairs, _bb_frame)
        print(io, "\n \"", frame, "\"")
        print(io, "\n   ")
        _kv_print_type(io, kT_pairs; _typeof = identity)
    end
end

_show_vframes(io::IO, bb::BlobBatch) =
    _show_kT_frames(io, bb.vframes, "Ram vframes: ") do kT_pairs, _bb_frame
        for (_, _b_frame) in _bb_frame
            for (key, val) in _b_frame
                push!(kT_pairs, string(key) => typeof(val))
            end
        end
    end

_show_dframes(io::IO, bb::BlobBatch) =
    _show_kT_frames(io, bb.dframes, "Ram dframes: ") do kT_pairs, _bb_frame
        for (key, val) in _bb_frame
            push!(kT_pairs, string(key) => typeof(val))
        end
    end

function _show_disk_files(io::IO, bb::BlobBatch; 
            filt = "", 
            fc = :normal, 
            bc = :normal,
            sc = :blue
        )
    
    _root = batchpath(bb)
    b_files = isdir(bb) ? readdir(_root; join = false) : []
    isempty(b_files) && return
    sort!(b_files; by = _bb_show_file_sortby)
    _npad = maximum(length.(b_files); init = 0)
    print(io, "\n\nDisk files: \n")
    for name in b_files
        path = joinpath(_root, name)
        endswith(path, ".jls") || continue
        contains(path, filt) || continue
        val, unit = _canonical_bytes(filesize(path))
        print(io, "   ")
        _file_str = rpad(string("\"", name, "\" "), _npad + 4, ' ')
        printstyled(io, _file_str; color = fc)
        print(io, " ")
        _size_str = string(round(val; digits = 3), " ", unit)
        printstyled(io, _size_str; color = sc)
        print(io, "\n")
    end
    print(io, "\ndisk usage: ")
    val, unit = _canonical_bytes(filesize(bb))
    _size_str = string(round(val; digits = 3), " ", unit)
    printstyled(io, _size_str; color = sc)
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