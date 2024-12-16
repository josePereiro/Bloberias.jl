## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
function _prefix_0x(dir)
    _prefset = Dict{String, Int}()
    for name in readdir(dir)
        pref = first(split(name, ".0x"))
        get!(_prefset, pref, 0)
        _prefset[pref] += 1
    end
    _prefset
end


## --.--. - .-. .- .--.-.- .- .---- ... . .-.-.-.- 
import Base.show
function Base.show(io::IO, B::Bloberia)
    print(io, "Bloberia")
    _isdir = isdir(B.root)
    _pretty_print_pairs(io, 
        "\n filesys", 
        B.root
    )
    _pretty_print_pairs(io, 
        "\n lock files", 
        lockcount(B)
    )
    _pretty_print_pairs(io, 
        "\n batch(es)", 
        _isdir ? batchcount(B) : 0
    )
    _toutflag, _vblobcount = _blobcount_tout(B, nothing, 5)
    _vblobcount = _toutflag ? string(">= ", _vblobcount) : _vblobcount
    _pretty_print_pairs(io, 
        "\n vblob(s)", 
        _isdir ? _vblobcount : 0
    )

    if _isdir
        _prefixhist = _prefix_0x(B.root)
        _prefixs = collect(keys(_prefixhist)) |> sort!
        print(io, "\n x0 prefixes: \n")
        for prex in _prefixs
            print(io, "   ")
            printstyled(io, prex; color = :normal)
            printstyled(io, " ["; color = :normal)
            printstyled(io, _prefixhist[prex]; color = :blue)
            printstyled(io, " folder(s)"; color = :blue)
            printstyled(io, "]"; color = :normal)
            println(io)
        end
    end

    val, unit = _isdir ? _canonical_bytes(filesize(B)) : (0.0, "bytes")
    _pretty_print_pairs(io, 
        "\n disk usage", 
        _isdir ? string(round(val; digits = 3), " ", unit) : 0.0
    )
end