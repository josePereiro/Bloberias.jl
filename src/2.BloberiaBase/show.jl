## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
import Base.show
function Base.show(io::IO, B::Bloberia)
    print(io, "Bloberia")
    _isdir = isdir(B.root)
    _pretty_print_pairs(io, 
        "\n filesys", 
        hasfilesys(B) ? B.root : ""
    )
    _pretty_print_pairs(io, 
        "\n batch(es)", 
        _isdir ? batchcount(B) : 0
    )
    _pretty_print_pairs(io, 
        "\n blob(s)", 
        _isdir ? vblobcount(B) : 0
    )
    val, unit = _isdir ? _canonical_bytes(filesize(B)) : (0.0, "bytes")
    _pretty_print_pairs(io, 
        "\n disk usage", 
        _isdir ? string(round(val; digits = 3), " ", unit) : 0.0
    )
end