

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
    include("0.Base/meta_interface.jl")
    include("0.Base/scope_interface.jl")
    include("0.Base/utils.jl")
    
    #! include 1.BlobyObjBase
    include("1.BlobyObjBase/lock.jl")
    
    #! include 2.BloberiaBase
    include("2.BloberiaBase/base.jl")
    include("2.BloberiaBase/blobbatch.jl")
    include("2.BloberiaBase/filesys.jl")
    include("2.BloberiaBase/iterator.jl")
    include("2.BloberiaBase/loading.jl")
    include("2.BloberiaBase/meta.jl")
    include("2.BloberiaBase/rablob.jl")
    include("2.BloberiaBase/serialize.jl")
    
    #! include 3.BlobyFramedObjBase
    include("3.BlobyFramedObjBase/base.jl")

    #! include 4.BlobBatchBase    
    include("4.BlobBatchBase/base.jl")
    include("4.BlobBatchBase/btblob.jl")
    include("4.BlobBatchBase/filesys.jl")
    include("4.BlobBatchBase/getframe.jl")
    include("4.BlobBatchBase/iterator.jl")
    include("4.BlobBatchBase/loading.jl")
    include("4.BlobBatchBase/meta.jl")
    include("4.BlobBatchBase/serialize.jl")
    
    #! include 5.AbstractBlobBase
    include("5.AbstractBlobBase/base.jl")
    
    #! include 6.btBlobBase       
    include("6.btBlobBase/base.jl")
    include("6.btBlobBase/getframe.jl")
    include("6.btBlobBase/serialize.jl")
    
    #! include 7.raBlobBase
    include("7.raBlobBase/base.jl")
    include("7.raBlobBase/filesys.jl")
    include("7.raBlobBase/getframe.jl")
    include("7.raBlobBase/loading.jl")
    include("7.raBlobBase/meta.jl")
    include("7.raBlobBase/serialize.jl")

    #! include 8.BlobyRefBase
    include("8.BlobyRefBase/base.jl")
    
    
    #! include 99.Utils
    
    @exportall_words()

end