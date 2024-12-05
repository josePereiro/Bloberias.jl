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
    _toutflag, _vblobcount = _vblobcount_tout(B, nothing, 5)
    _vblobcount = _toutflag ? string(">= ", _vblobcount) : _vblobcount
    _pretty_print_pairs(io, 
        "\n vblob(s)", 
        _isdir ? _vblobcount : 0
    )

    val, unit = _isdir ? _canonical_bytes(filesize(B)) : (0.0, "bytes")
    _pretty_print_pairs(io, 
        "\n disk usage", 
        _isdir ? string(round(val; digits = 3), " ", unit) : 0.0
    )
end