

module Bloberias

    import Serialization
    
    using MassExport
    using OrderedCollections
    using Dates
    using Serialization
    using UUIDs
    using Base.Threads
    using SimpleLockFiles

    #! include .

    #! include 0.Base
    include("0.Base/0_types.jl")
    include("0.Base/kv_interface.jl")
    include("0.Base/utils.jl")

    #! include 1.BlobyObjBase
    include("1.BlobyObjBase/base.jl")
    include("1.BlobyObjBase/lock.jl")
    
    #! include 2.BlobyFrameBase
    include("2.BlobyFrameBase/base.jl")
    
    #! include 3.AbstractBlobBase
    include("3.AbstractBlobBase/base.jl")

    #! include 4.BloberiaBase
    include("4.BloberiaBase/base.jl")
    include("4.BloberiaBase/blobbatch.jl")
    include("4.BloberiaBase/iterator.jl")
    include("4.BloberiaBase/serialize.jl")
    include("4.BloberiaBase/show.jl")
    

    #! include 5.BlobBatchBase
    include("5.BlobBatchBase/base.jl")
    include("5.BlobBatchBase/blob.jl")
    include("5.BlobBatchBase/iterator.jl")
    include("5.BlobBatchBase/serialize.jl")
    include("5.BlobBatchBase/show.jl")
    
    #! include 6.BlobBase
    include("6.BlobBase/base.jl")

    #! include 7.BlobyRefBase
    include("7.BlobyRefBase/base.jl")
    include("7.BlobyRefBase/deref.jl")
    include("7.BlobyRefBase/ref.jl")
    
    #! include 8.RefCacher
    include("8.RefCacher/base.jl")
    include("8.RefCacher/deref.jl")

    @exportall_words()

end