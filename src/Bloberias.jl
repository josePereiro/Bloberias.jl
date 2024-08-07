# TODO: Change name to Bloberias

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
    include("Base/scope_interface.jl")
    include("Base/utils.jl")
    
    #! include BloberiaBase
    include("BloberiaBase/base.jl")
    include("BloberiaBase/blobbatch.jl")
    include("BloberiaBase/iterator.jl")
    include("BloberiaBase/filesys.jl")
    include("BloberiaBase/lock.jl")

    #! include BlobBase
    include("BlobBase/base.jl")
    
    #! include BlobBatchBase
    include("BlobBatchBase/base.jl")
    include("BlobBatchBase/iterator.jl")
    include("BlobBatchBase/blob.jl")
    include("BlobBatchBase/filesys.jl")
    include("BlobBatchBase/loading.jl")
    include("BlobBatchBase/lock.jl")
    include("BlobBatchBase/serialize.jl")

    #! include Utils
    include("Utils/exportall.jl")

    @_exportall_words()

end