

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
    
    #! include 2.AbstractBlobBase
    include("2.AbstractBlobBase/base.jl")
    include("2.AbstractBlobBase/lock.jl")
    include("2.AbstractBlobBase/tree.depot.jl")
    include("2.AbstractBlobBase/tree.depotdisk.jl")
    include("2.AbstractBlobBase/tree.disk.jl")
    include("2.AbstractBlobBase/tree.pub.jl")

    #! include 3.BloberiaBase
    include("3.BloberiaBase/base.jl")
    include("3.BloberiaBase/blobbatch.jl")
    include("3.BloberiaBase/iterator.jl")
    include("3.BloberiaBase/serialize.jl")
    include("3.BloberiaBase/tree.interface.jl")
    
    #! include 4.BlobBatchBase
    include("4.BlobBatchBase/base.jl")
    include("4.BlobBatchBase/blob.jl")
    include("4.BlobBatchBase/iterator.jl")
    include("4.BlobBatchBase/serialize.jl")
    include("4.BlobBatchBase/tree.interface.jl")
    
    #! include 5.bBlobBase
    include("5.bBlobBase/base.jl")
    include("5.bBlobBase/tree.interface.jl")
    

    @exportall_words()

    # TODO/Del only for dev
    @exportall_underscore()

end