using Bloberias
using Base.Threads
using Random
using Test

# .-- . -. - .--..- -- .- - --..-.-.- .- -.--
# TODO: Use aqua

# .-- . -. - .--..- -- .- - --..-.-.- .- -.--
@testset "Bloberias.jl" begin
    ## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
    B_ROOT = joinpath(tempname(), "B")
    atexit(() -> rm(B_ROOT; force = true, recursive = true)) 

    try

        ## .-- . -. - .--..- -- .
        println("\n", "-"^40)
        @info("Test threaded iterator")
        let
            B = Bloberia(B_ROOT)
            rm(B)

            nbbs = 10
            bs_per_bb = 10
            for bbi in 1:nbbs
                bb = blobbatch!(B, "db$bbi")
                for bi in 1:bs_per_bb
                    b = blob!(bb, bi)
                    b["rand"] = rand()
                end
                serialize!(bb)
            end
            @test batchcount(B) == nbbs

            # serial
            _wt = 0.2
            _t = @elapsed foreach_batch(B; 
                ch_size = nthreads(),
                n_tasks = 1
            ) do bb
                @show threadid()
                sleep(_wt)
            end
            @show _t
            @test _t >= nbbs * _wt

            # threaded
            if nthreads() > 1
                _wt = 0.2
                _t = @elapsed foreach_batch(B; 
                    ch_size = nthreads(),
                    n_tasks = nbbs
                ) do bb
                    @show threadid()
                    sleep(_wt)
                end
                @show _t
                @test _t <= nbbs * _wt
            end

        end
        
        ## .-- . -. - .--..- -- .
        println("\n", "-"^40)
        @info("Test RefCacher")
        let
            B = Bloberia(B_ROOT)
            rm(B)

            # write
            _refs = BlobyRef[]
            _acc0 = 0.0
            bb = blobbatch!(B, "db")
            for bi in 1:100
                b = blob!(bb, bi)
                rn = rand()
                _acc0 += rn
                b["rand"] = rn
                ref = blobyref(b, "rand"; rT = Float64, abs = true)
                push!(_refs, ref)
            end
            serialize!(bb)

            # test iterato
            _acc = 0
            for _bb in B
                for b in _bb
                    _acc += b["rand"]
                end
            end
            @test _acc == _acc0
            
            # no cache
            _acc = 0.0
            @time _alloc_non_cached = @allocated for ref in _refs
                _acc += ref[]
            end
            @show _alloc_non_cached
            @test _acc == _acc0

            # cache
            _acc = 0.0
            rc = RefCacher()
            @time _alloc_cached = @allocated for ref in _refs
                _acc += rc[ref]
            end
            @show _alloc_cached
            @test _acc == _acc0

            # rel ref
            _acc = 0.0
            @time _alloc_rel = @allocated for ref in _refs
                _acc += bb[ref]
            end
            @show _alloc_rel
            @test _acc == _acc0

            @test _alloc_rel < _alloc_cached 
            @test _alloc_cached < _alloc_non_cached 
        end
        
        ## .-- . -. - .--..- -- .
        println("\n", "-"^40)
        @info("Test blobyref")
        let
            ## Ram only
            B = Bloberia(B_ROOT)
            rc = RefCacher()
            rm(B)

            ref = blobyref(B)
            @test B.root == ref[].root      # abs deref
            @test B.root == B[ref].root     # rel deref
            @test B.root == rc[ref].root     # rel deref
            
            # non absolute path
            ref = blobyref(B; abs = false)
            @test B.root == ref[].root       # abs deref (bloberia is the root, always abs)
            @test B.root == B[ref].root      # rel deref
            
            bb = blobbatch!(B, "bb")
            # rm(bb)
            ref = blobyref(bb; abs = true)
            @test bb.root == ref[].root       # abs deref
            @test bb.root == bb[ref].root     # rel deref
            @test bb.root == B[ref].root      # rel deref
            @test bb.root == rc[ref].root     # rel deref
            
            # non absolute path
            ref = blobyref(bb; abs = false)
            @test_throws ["B.root"] bb.root == ref[].root  # fail (B missing)
            @test bb.root == bb[ref].root     # rel deref
            @test bb.root == B[ref].root      # rel deref
        
            b = blob!(bb, 0)
            ref = blobyref(b)
            @test b.bb.root == ref[].bb.root    # abs deref
            @test b.bb.root == b[ref].bb.root   # rel deref
            @test b.uuid == ref[].uuid          # abs deref
            @test b.uuid == bb[ref].uuid        # rel deref
            @test b.uuid == rc[ref].uuid        # rel deref
            
            # non absolute path
            ref = blobyref(b; abs = false)
            @test_throws ["B.root"] b.uuid == ref[].uuid  # fail (B missing)
            @test b.uuid == bb[ref].uuid       # rel deref
            @test b.bb.root == b[ref].bb.root   # rel deref
            
            # blob(ref) only work if disk version exist
            # the same for ref[]
            # but blob!(ref) creates a new blob
            ref = blobyref(b)
            b1 = blob(ref)                      
            @test b.uuid == b1.uuid             #
            @test b.bb.root == b1.bb.root       #
            @test b.bb.root == b[ref].bb.root   # rel deref
            @test b.uuid == b1[ref].uuid        # rel deref
            @test b.uuid == rc[ref].uuid        # rel deref
        
            ref = blobyref(b; abs = false)
            @test_throws ["B.root"] blob(ref)     # fail (B missing)             
        
            # Vals
            rm(B)
            empty!(B)
            empty!(bb)
        
            ref = blobyref(B, "ref.test"; rT = Int)
            B["ref.test"] = 1
            @test B[ref] == 1
            @test_throws ["not found"] rc[ref] == 1  # this fail because values needs disk
            
            ## Disk interactions
            rm(B)
            empty!(B)
            empty!(bb)
            empty!(rc)
            bb = blobbatch!(B, "db")
            b = blob!(bb, 0)
            for ab in [B, bb, b]
                # @info "Testing" typeof(ab)
                ref = blobyref(ab, "ref.test"; rT = Int)
                @test_throws ["not found"] ref[] # val does not exist anywhere
                ab["ref.test"] = 1
                @test ab[ref] == 1 # now it exist on ram
                ab[ref] = 2
                @test_throws ["not found"] ref[] # but ram is unreachable 
                @test ab[ref] == 2 # at least you do a relative deref
                
                serialize!(B)
                serialize!(bb)
                empty!(B) # clear ram
                empty!(bb) # clear ram
                
                # load from disk
                @test ref[] == 2
                @test ab[ref] == 2
                @test rc[ref] == 2
            end
        end

        ## .-- . -. - .--..- -- .
        println("\n", "-"^40)
        @info("Test hashio!")
        let
            B = Bloberia(B_ROOT)
            rm(B)
            # ram only
            bb = blobbatch!(B, "bb")
            b = blob!(bb, 0)
        
            Random.seed!(123)
            for ab in [b, bb]
                @show typeof(ab)
                for it in 1:10
                    mat = rand(10,10)
                    # abs
                    ref = hashio!(ab, mat, :get!)
                    show(ref); println()
                    @test objectid(ab[ref]) == objectid(mat)
                    serialize!(bb)
                    @test objectid(ref[]) != objectid(mat)
                    @test mat == ab[ref]
                    @test mat == ref[]
                    
                    # rel
                    ref = hashio!(ab, mat; abs = false)
                    show(ref); println()
                    @test objectid(ab[ref]) == objectid(mat) # still the same object
                    @test mat == ab[ref]
                end 
            end
        end

        ## .-- . -. - .--..- -- .
        println("\n", "-"^40)
        @info("Test getindex/setindex! interface")
        let
            B = Bloberia(B_ROOT)
            rm(B)
            # ram only
            bb = blobbatch!(B, "bb")
            b = blob!(bb, 0)
            for bobj in [B, bb, b]
                _runned = get!(bobj, "key0", 1)
                @test _runned == 1
                # ignore defaults (data on ram)
                _runned = get!(bobj, "key0", 2)
                @test _runned == 1
                _runned = get(bobj, "key0", 3)
                @test _runned == 1
            end
            serialize!(B)
            serialize!(bb)
        
            # load
            empty!(B)
            empty!(bb)
            @test !hasframe_ram(B)
            @test !hasframe_ram(bb)
            @test hasframe_disk(B)
            @test hasframe_disk(bb)
            for bobj in [B, bb, b]
                # ignore defaults (data on disk)
                _runned = get!(bobj, "key0", 2)
                @test _runned == 1
                _runned = get(bobj, "key0", 3)
                @test _runned == 1
            end
        end

        ## .-- . -. - .--..- -- .
        println("\n")
        
    finally
        rm(B_ROOT; recursive = true, force = true)
    end
end

## .-- . -. - .--..- -- .- - --..-.-.- .- -.--

# @testset "Bloberias.jl" begin

    

#     try; for testi in 1:1 # repeat many times
#         println("-"^30)
#         @show testi

#         ## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
#         # Test full interface
#         let
#             B = Bloberia(B_ROOT)
#             rm(B)
#             bb = blobbatch!(B) # default
        
#             _lim = 11
#             bb_meta = getmeta(bb)
#             bb_meta["config.blobs.lim"] = _lim
#             while !isfullbatch(bb)
#                 b = rblob!(bb)
#                 b["rand"] = rand()
#             end
#             @test blobcount(bb) == _lim
#         end
        
#         ## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
#         # blobyio! interface
#         let
#             B = Bloberia(B_ROOT)
#             rm(B.root; force = true, recursive = true)
#             bb = blobbatch!(B, "custom")
#             db = dblob(bb)
#             vb = vblob!(bb, 0)

#             _dat0 = [1,2,3]
#             frame = string(hash(_dat0))
#             for b in [db, vb]
#                 blobyio!(b, :get!, frame, "+1") do
#                     return _dat0 .+ 1
#                 end
#                 @test b[frame, "+1"] == _dat0 .+ 1
#                 serialize!(bb)
#             end
            
#             # check again but from loading
#             # empty!
#             empty!(db)
#             @test isempty(db.bb.bbframes)
#             _ref1 = blobyio!(db, :get!, frame, "+1") do
#                 return "not to load"
#             end
#             @test _ref1[] == _dat0 .+ 1
            
#             empty!(bb)
#             @test isempty(bb)
#             @test isempty(bb.buuids)
#             @test isempty(bb.bbframes)
#             @test isempty(bb.bframes)
#             vb = vblob(bb, 1) # first blob
#             _ref1 = blobyio!(vb, :get!, frame, "+1") do
#                 return "not to load"
#             end
#             @test _ref1[] == _dat0 .+ 1

#             # Shadow copy
#             bb = copy(bb) # shadow copy
#             db = dblob(bb)
#             @test isempty(bb)
#             _ref1 = blobyio!(db, :get!, frame, "+1") do
#                 return "not to load"
#             end
#             @test _ref1[] == _dat0 .+ 1

#             bb = copy(bb) # shadow copy
#             @test isempty(bb)
#             vb = vblob(bb, 1) # first blob
#             _ref1 = blobyio!(vb, :get!, frame, "+1") do
#                 return "not to load"
#             end
#             @test _ref1[] == _dat0 .+ 1

#         end
        
#         ## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
#         # Test refs
#         let
#             B = Bloberia(B_ROOT)
#             rm(B; force = true)
#             bb = blobbatch!(B, "globals")
#             rc = RefCacher()
#             b = dblob(bb)
#             for b in [dblob(bb), vblob!(bb, 0)]
#                 token = rand()
#                 b_ref = blobyio!(b, :set!, "0", "key") do
#                     token
#                 end
#                 serialize!(bb)
#                 serialize!(B)
                
#                 @test deref!(rc, b_ref) == token
#                 @test deref(b_ref) == token
#                 @test deref(B, b_ref) == token
#                 @test deref(bb, b_ref) == token

#                 @test b_ref[] == token
#                 @test rc[b_ref] == token
#                 @test bb[b_ref] == token
#             end
#         end

#         # TODO: update tests
#         ## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
#         # blobbatches interface
#         let
#             B = Bloberia(B_ROOT)
#             rm(B; force = true)

#             bb0 = headbatch!(B, "bb0")
#             bb_lim = 100
#             vbloblim!(bb0, bb_lim)
            
#             # write to ram
#             _token = rand()
#             for it in 1:(bb_lim ÷ 2)
#                 b = rblob!(bb0)
#                 b["it"] = it # default frame
#                 b["f0", "_token"] = _token 
#                 @test b["f0", "_token"] == _token # test getindex/setindex!
#                 isfullbatch(bb0) && break
#             end
#             @test !isfullbatch(bb0)
#             @test hasframe(bb0, "f0")
#             @test batchcount(B) == 0
#             serialize!(bb0)
#             @test batchcount(B) == 1
            
#             _bbs = collect(eachbatch(B))
#             @test length(_bbs) == 1
            
#             bb1 = headbatch!(B, "bb0") # take the same full batch
#             @test hasframe(bb1, "f0")
#             @test batchpath(bb0) == batchpath(bb1)
#             @test length(bb0) == length(bb1)

#             # test load/getindex
#             # it must keep the order
#             for (it, b) in enumerate(bb1)
#                 @test b["it"] == it # default frame
#                 @test b["f0", "_token"] == _token
#             end
            
#             bb2 = blobbatch!(B, "bb2") # new batch
#             @test length(bb2) == 0
#             @test batchpath(bb0) != batchpath(bb2)
#             @test length(bb2) != length(bb1)

#             # write more
#             for it in 1:(bb_lim * 10)
#                 b = rblob!(bb0)
#                 b["it"] = it # deault frame
#                 isfullbatch(bb0) && break
#             end
#             @test isfullbatch(bb0)
#             @test length(bb0) == bb_lim
#             @test batchcount(B) == 1
#             serialize!(bb0)
#             @test batchcount(B) == 1
            
#             # it should not find bb0 (the only serialized)
#             bb3 = headbatch!(B, "bb")
#             @test length(bb3) == 0
#             @test batchpath(bb0) != batchpath(bb2)
#             @test length(bb0) != length(bb3)
#         end

#         ## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
#         # dBlobs
#         let
#             B = Bloberia(B_ROOT)
#             rm(B; force = true)
#             bb = blobbatch!(B) # default

#             db1 = dblob(bb) 
#             db2 = dblob(bb)
            
#             # custom frame ("blo")
#             db1["blo", "bla"] = rand(5,5)
#             serialize!(bb, "blo") 
#             @test db2["blo", "bla"] == db1["blo", "bla"]
#         end


#         ## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
#         # meta interface
#         let
#             B = Bloberia(B_ROOT)
#             rm(B; force = true)
#             bb = blobbatch!(B, "0")
            
#             for obj in [B, bb]
#                 println(typeof(obj))
                
#                 mfile = meta_jlspath(obj)
#                 @test !isfile(mfile)
                
#                 meta = getmeta(obj)
#                 _dat0 = rand(10)
#                 meta["bla"] = _dat0
#                 @test !isfile(mfile)
#                 @test all(meta["bla"] .== _dat0)

#                 empty!(getmeta(obj))
#                 meta = getmeta(obj)
#                 @test isempty(meta) # no disk copy yet
                
#                 # serialize
#                 meta["bla"] = _dat0
#                 serialize!(obj; ignoreempty = false) # create disk copy

#                 # test load
#                 empty!(meta)
#                 meta = getmeta(obj) # data is loaded on demand
#                 @test all(meta["bla"] .== _dat0) 
#             end
#         end

#         ## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
#         # lock test
#         testi == 1 && let
#             B = Bloberia(B_ROOT)
#             rm(B.root; force = true, recursive = true)
#             bb = blobbatch!(B, "0")
#             db = dblob(bb)
#             vb = vblob!(bb, 0)

#             _bos = [B, bb, db, vb]
#             _dt = 1
#             # @show _dt
#             # no lock
#             _t = @elapsed @sync for bo in _bos
#                 @async sleep(_dt)
#             end
#             # @show _t
#             @test _t < length(_bos) * _dt

#             # per object lock
#             # effectively no lock
#             _t = @elapsed @sync for bo in _bos
#                 @async lock(bo) do
#                     @test true
#                     sleep(_dt)
#                 end
#             end
#             # @show _t
#             @test _t < length(_bos) * _dt

#             # same lock
#             _t = @elapsed @sync for bo in _bos
#                 B = bloberia(bo)
#                 @async lock(B) do
#                     @test true
#                     sleep(_dt)
#                 end
#             end
#             # @show _t
#             @test _t >= length(_bos) * _dt

#         end
    
#     end; finally
#         rm(B_ROOT; force = true, recursive = true)
#     end

# end
