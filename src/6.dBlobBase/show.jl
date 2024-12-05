import Base.show
function Base.show(io::IO, db::dBlob)
    print(io, "dBlob(bb", repr(db.bb.id), ")")
    
    # dframes
    _show_dframes(io, db.bb)

    # disk
    _show_disk_files(io, db.bb; filt = ".dframe.")

    nothing

end