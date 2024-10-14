

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
    include("0.Base/lite_interface.jl")
    include("0.Base/lock.jl")
    include("0.Base/meta_interface.jl")
    include("0.Base/scope_interface.jl")
    include("0.Base/utils.jl")
    
    #! include 1.BloberiaBase
    include("1.BloberiaBase/base.jl")
    include("1.BloberiaBase/blobbatch.jl")
    include("1.BloberiaBase/filesys.jl")
    include("1.BloberiaBase/iterator.jl")
    include("1.BloberiaBase/loading.jl")
    include("1.BloberiaBase/lock.jl")
    include("1.BloberiaBase/meta.jl")
    include("1.BloberiaBase/rablob.jl")
    include("1.BloberiaBase/serialize.jl")
    
    #! include 2.BlobBatchBase
    include("2.BlobBatchBase/base.jl")
    include("2.BlobBatchBase/btblob.jl")
    include("2.BlobBatchBase/filesys.jl")
    include("2.BlobBatchBase/getframe.jl")
    include("2.BlobBatchBase/iterator.jl")
    include("2.BlobBatchBase/loading.jl")
    include("2.BlobBatchBase/lock.jl")
    include("2.BlobBatchBase/meta.jl")
    include("2.BlobBatchBase/serialize.jl")
    
    #! include 3.AbstractBlobBase
    include("3.AbstractBlobBase/base.jl")

    #! include 4.btBlobBase
    include("4.btBlobBase/base.jl")
    include("4.btBlobBase/getframe.jl")
    include("4.btBlobBase/lock.jl")
    include("4.btBlobBase/serialize.jl")
    
    #! include 5.raBlobBase
    include("5.raBlobBase/base.jl")
    include("5.raBlobBase/filesys.jl")
    include("5.raBlobBase/getframe.jl")
    include("5.raBlobBase/loading.jl")
    include("5.raBlobBase/lock.jl")
    include("5.raBlobBase/meta.jl")
    include("5.raBlobBase/serialize.jl")
    
    #! include 6.BlobyRefBase
    include("6.BlobyRefBase/base.jl")
    
    #! include 99.Utils
    
    @exportall_words()

end