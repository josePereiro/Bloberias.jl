# import Base.show
# function Base.show(io::IO, db::dBlob)
#     print(io, "dBlob(bb", repr(db.bb.id), ")")
    
#     # bbframes
#     _show_bbframes(io, db.bb)

#     # disk
#     _show_disk_files(io, db.bb; filt = ".bbframe.")

#     nothing

# end