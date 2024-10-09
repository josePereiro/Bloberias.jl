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
    
    #! include 3.btBlobBase
    include("3.btBlobBase/base.jl")
    include("3.btBlobBase/getframe.jl")
    include("3.btBlobBase/lock.jl")
    
    #! include 4.raBlobBase
    include("4.raBlobBase/base.jl")
    include("4.raBlobBase/filesys.jl")
    include("4.raBlobBase/loading.jl")
    include("4.raBlobBase/lock.jl")
    include("4.raBlobBase/serialize.jl")
    
    #! include 99.Utils
    include("99.Utils/exportall.jl")
    
    @_exportall_words()

end