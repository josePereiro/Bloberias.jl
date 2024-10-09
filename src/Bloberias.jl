# TODO:
# - Make random blobs hold its content
# - that is, move it away from Bloberias
# - otherwise you can not load other rablobs at the same time
# think about raBlob as a batch of a single blob, so it needs to have batch+blob functionality

module Bloberias

    import Serialization
    
    using OrderedCollections
    using Dates
    using Serialization
    using UUIDs
    using Base.Threads
    using SimpleLockFiles

    #! include .

    #! include Base
    include("Base/0_types.jl")
    include("Base/kv_interface.jl")
    include("Base/lite_interface.jl")
    include("Base/lock.jl")
    include("Base/meta_interface.jl")
    include("Base/scope_interface.jl")
    include("Base/utils.jl")
    
    #! include BloberiaBase
    include("BloberiaBase/base.jl")
    include("BloberiaBase/blobbatch.jl")
    include("BloberiaBase/filesys.jl")
    include("BloberiaBase/iterator.jl")
    include("BloberiaBase/loading.jl")
    include("BloberiaBase/lock.jl")
    include("BloberiaBase/rablob.jl")
    include("BloberiaBase/serialize.jl")

    #! include btBlobBase
    include("btBlobBase/base.jl")
    include("btBlobBase/lock.jl")
    
    #! include raBlobBase
    include("raBlobBase/base.jl")
    include("raBlobBase/lock.jl")
    
    #! include BlobBatchBase
    include("BlobBatchBase/base.jl")
    include("BlobBatchBase/btblob.jl")
    include("BlobBatchBase/filesys.jl")
    include("BlobBatchBase/iterator.jl")
    include("BlobBatchBase/loading.jl")
    include("BlobBatchBase/lock.jl")
    include("BlobBatchBase/serialize.jl")

    #! include Utils
    include("Utils/exportall.jl")

    @_exportall_words()

end