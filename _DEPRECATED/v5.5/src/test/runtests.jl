using Bloberias
using Base.Threads
using Test

## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
# TODO: Use aqua

## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
@testset "Bloberias.jl" begin

    ## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
    B_ROOT = joinpath(tempname(), "db")
    atexit(() -> rm(B_ROOT; force = true, recursive = true)) 

    try; for testi in 1:1 # repeat many times
        println("-"^30)
        @show testi

        ## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
        # Test full interface
        let
            B = Bloberia(B_ROOT)
            rm(B)
            bb = blobbatch!(B) # default
        
            _lim = 11
            bb_meta = getmeta(bb)
            bb_meta["config.blobs.lim"] = _lim
            while !isfullbatch(bb)
                b = rblob!(bb)
                b["rand"] = rand()
            end
            @test vblobcount(bb) == _lim
        end
        
        ## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
        # blobyio! interface
        let
            B = Bloberia(B_ROOT)
            rm(B.root; force = true, recursive = true)
            bb = blobbatch!(B, "custom")
            db = dblob(bb)
            vb = vblob!(bb, 0)

            _dat0 = [1,2,3]
            frame = string(hash(_dat0))
            for b in [db, vb]
                blobyio!(b, :get!, frame, "+1") do
                    return _dat0 .+ 1
                end
                @test b[frame, "+1"] == _dat0 .+ 1
                serialize!(bb)
            end
            
            # check again but from loading
            # empty!
            empty!(db)
            @test isempty(db.bb.bbframes)
            _ref1 = blobyio!(db, :get!, frame, "+1") do
                return "not to load"
            end
            @test _ref1[] == _dat0 .+ 1
            
            empty!(bb)
            @test isempty(bb)
            @test isempty(bb.buuids)
            @test isempty(bb.bbframes)
            @test isempty(bb.bframes)
            vb = vblob(bb, 1) # first blob
            _ref1 = blobyio!(vb, :get!, frame, "+1") do
                return "not to load"
            end
            @test _ref1[] == _dat0 .+ 1

            # Shadow copy
            bb = copy(bb) # shadow copy
            db = dblob(bb)
            @test isempty(bb)
            _ref1 = blobyio!(db, :get!, frame, "+1") do
                return "not to load"
            end
            @test _ref1[] == _dat0 .+ 1

            bb = copy(bb) # shadow copy
            @test isempty(bb)
            vb = vblob(bb, 1) # first blob
            _ref1 = blobyio!(vb, :get!, frame, "+1") do
                return "not to load"
            end
            @test _ref1[] == _dat0 .+ 1

        end
        
        ## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
        # Test refs
        let
            B = Bloberia(B_ROOT)
            rm(B; force = true)
            bb = blobbatch!(B, "globals")
            rc = RefCacher()
            b = dblob(bb)
            for b in [dblob(bb), vblob!(bb, 0)]
                token = rand()
                b_ref = blobyio!(b, :set!, "0", "key") do
                    token
                end
                serialize!(bb)
                serialize!(B)
                
                @test deref!(rc, b_ref) == token
                @test deref(b_ref) == token
                @test deref(B, b_ref) == token
                @test deref(bb, b_ref) == token

                @test b_ref[] == token
                @test rc[b_ref] == token
                @test bb[b_ref] == token
            end
        end

        # TODO: update tests
        ## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
        # blobbatches interface
        let
            B = Bloberia(B_ROOT)
            rm(B; force = true)

            bb0 = headbatch!(B, "bb0")
            bb_lim = 100
            vbloblim!(bb0, bb_lim)
            
            # write to ram
            _token = rand()
            for it in 1:(bb_lim ÷ 2)
                b = rblob!(bb0)
                b["it"] = it # default frame
                b["f0", "_token"] = _token 
                @test b["f0", "_token"] == _token # test getindex/setindex!
                isfullbatch(bb0) && break
            end
            @test !isfullbatch(bb0)
            @test hasframe(bb0, "f0")
            @test batchcount(B) == 0
            serialize!(bb0)
            @test batchcount(B) == 1
            
            _bbs = collect(eachbatch(B))
            @test length(_bbs) == 1
            
            bb1 = headbatch!(B, "bb0") # take the same full batch
            @test hasframe(bb1, "f0")
            @test batchpath(bb0) == batchpath(bb1)
            @test length(bb0) == length(bb1)

            # test load/getindex
            # it must keep the order
            for (it, b) in enumerate(bb1)
                @test b["it"] == it # default frame
                @test b["f0", "_token"] == _token
            end
            
            bb2 = blobbatch!(B, "bb2") # new batch
            @test length(bb2) == 0
            @test batchpath(bb0) != batchpath(bb2)
            @test length(bb2) != length(bb1)

            # write more
            for it in 1:(bb_lim * 10)
                b = rblob!(bb0)
                b["it"] = it # deault frame
                isfullbatch(bb0) && break
            end
            @test isfullbatch(bb0)
            @test length(bb0) == bb_lim
            @test batchcount(B) == 1
            serialize!(bb0)
            @test batchcount(B) == 1
            
            # it should not find bb0 (the only serialized)
            bb3 = headbatch!(B, "bb")
            @test length(bb3) == 0
            @test batchpath(bb0) != batchpath(bb2)
            @test length(bb0) != length(bb3)
        end

        ## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
        # dBlobs
        let
            B = Bloberia(B_ROOT)
            rm(B; force = true)
            bb = blobbatch!(B) # default

            db1 = dblob(bb) 
            db2 = dblob(bb)
            
            # custom frame ("blo")
            db1["blo", "bla"] = rand(5,5)
            serialize!(bb, "blo") 
            @test db2["blo", "bla"] == db1["blo", "bla"]
        end


        ## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
        # meta interface
        let
            B = Bloberia(B_ROOT)
            rm(B; force = true)
            bb = blobbatch!(B, "0")
            
            for obj in [B, bb]
                println(typeof(obj))
                
                mfile = meta_jlspath(obj)
                @test !isfile(mfile)
                
                meta = getmeta(obj)
                _dat0 = rand(10)
                meta["bla"] = _dat0
                @test !isfile(mfile)
                @test all(meta["bla"] .== _dat0)

                empty!(getmeta(obj))
                meta = getmeta(obj)
                @test isempty(meta) # no disk copy yet
                
                # serialize
                meta["bla"] = _dat0
                serialize!(obj; ignoreempty = false) # create disk copy

                # test load
                empty!(meta)
                meta = getmeta(obj) # data is loaded on demand
                @test all(meta["bla"] .== _dat0) 
            end
        end

        ## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
        # lock test
        testi == 1 && let
            B = Bloberia(B_ROOT)
            rm(B.root; force = true, recursive = true)
            bb = blobbatch!(B, "0")
            db = dblob(bb)
            vb = vblob!(bb, 0)

            _bos = [B, bb, db, vb]
            _dt = 1
            # @show _dt
            # no lock
            _t = @elapsed @sync for bo in _bos
                @async sleep(_dt)
            end
            # @show _t
            @test _t < length(_bos) * _dt

            # per object lock
            # effectively no lock
            _t = @elapsed @sync for bo in _bos
                @async lock(bo) do
                    @test true
                    sleep(_dt)
                end
            end
            # @show _t
            @test _t < length(_bos) * _dt

            # same lock
            _t = @elapsed @sync for bo in _bos
                B = bloberia(bo)
                @async lock(B) do
                    @test true
                    sleep(_dt)
                end
            end
            # @show _t
            @test _t >= length(_bos) * _dt

        end
    
    end; finally
        rm(B_ROOT; force = true, recursive = true)
    end

end
