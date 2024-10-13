using Bloberias
using Base.Threads
using Test

@testset "Bloberias.jl" begin
    
    # TODO: update tests

    ## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
    B_ROOT = joinpath(tempname(), "db")
    atexit(() -> rm(B_ROOT; force = true, recursive = true)) 

    for testi in 1:100 # repeat many times
        println("-"^30)
        @show testi

        ## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
        # blobbatches interface
        let
            B = Bloberia(B_ROOT)
            rm(B; force = true)
            
            bb0 = headbatch!(B)
            bb_lim = 100
            setmeta!(B, "batches.blobs.lim", bb_lim)

            # write to ram
            _token = rand()
            for it in 1:(bb_lim ÷ 2)
                b = blob!(bb0)
                b["it"] = it # default frame 0
                @test b["it"] == it # test getindex/setindex!
                b["1", "_token"] = _token # custom frame 0
                @test b["1", "_token"] == _token # test getindex/setindex!
                isfullbatch(bb0) && break
            end
            @test !isfullbatch(bb0)
            @test hasframe(bb0, "1")
            serialize(bb0)
            
            _bbs = collect(eachbatch(B))
            @test length(_bbs) == 1
            
            bb1 = headbatch!(B) # new non full batch
            @test hasframe(bb1, "1")
            @test bb0.uuid == bb1.uuid
            @test length(bb0) == length(bb1)

            # test load/getindex
            # it must keep the order
            for (it, b) in enumerate(bb1)
                @test b["it"] == it 
                @test b["1", "_token"] == _token
            end
            
            bb2 = blobbatch!(B) # new batch
            @test length(bb2) == 0
            @test bb0.uuid != bb2.uuid
            @test length(bb2) != length(bb1)

            # write more
            for it in 1:(bb_lim * 10)
                b = blob!(bb0)
                b["it"] = it # deault frame
                isfullbatch(bb0) && break
            end
            @test isfullbatch(bb0)
            @test length(bb0) == bb_lim
            serialize(bb0)

            bb3 = headbatch!(B)
            @test length(bb3) == 0
            @test bb0.uuid != bb3.uuid
            @test length(bb0) != length(bb3)

        end

        ## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
        # raBlobs
        let
            B = Bloberia(B_ROOT)
            rm(B; force = true)

            rb1 = blob!(B, "test")
            serialize(rb1) 
            rb2 = blob(B, "test")
            
            # default frame 
            rb1["bla"] = rand(5,5)
            serialize(rb1) 
            @test rb1["bla"] == rb2["bla"]
            
            # custom frame ("blo")
            rb1["blo", "bla"] = rand(5,5)
            serialize(rb1) 
            @test rb2["blo", "bla"] == rb1["blo", "bla"]
        end


        ## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
        # meta interface
        let
            B = Bloberia(B_ROOT)
            rm(B; force = true)
            b = blob!(B)
            bb = blobbatch!(B)
            
            for obj in [B, b, bb]
                println(typeof(obj))
                
                mfile = meta_framepath(obj)
                @test !isfile(mfile)
                
                meta0 = getmeta(obj)
                _dat0 = rand(10)
                setmeta!(obj, "bla", _dat0)
                @test !isfile(mfile)
                @test all(meta0["bla"] .== getmeta(obj, "bla"))

                empty!(getmeta(obj))
                meta1 = getmeta(obj)
                @test isempty(meta1) # no disk copy yet
                
                setmeta!(obj, "bla", _dat0)
                serialize(obj; ignoreempty = false) # create disk copy
                empty!(getmeta(obj))
                @test all(getmeta(obj, "bla") .== _dat0) # data is loaded on demand
            end
        end
    
    end # for testi

end
