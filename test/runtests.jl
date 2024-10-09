using Bloberias
using Base.Threads
using Test

@testset "Bloberias.jl" begin
    
    # TODO: update tests

    ## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
    let 
        B_ROOT = joinpath(@__DIR__, "db")
        B = Bloberia(B_ROOT)

        atexit(() -> rm(B_ROOT; force = true, recursive = true)) 

        ## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
        # INPUT
        let    
            rm(B_ROOT; force = true, recursive = true)
            # BlobBatches
            @threads :static for bbi in 1:10
                lock(B) do
                    bb = blobbatch!(B, "global")
                    N = Int(1e2)
                    for i in 1:N
                        b = blob!(bb) # create a new blob linked to bb
                        b["i"] = rand([i, "A"]) # add field 'j' to default frame '0'
                        b["EP.v1", "epm"] = Dict("B" => 2) # add field 'epm' to custom frame 'EP.v1'
                        b["EP.v1", "j"] = i*i # add field 'j' to custom frame 'EP.v1'
                        merge!(b, @litescope()) # this will overwrite "i"
                        # rollserialize!(bb, 100) # serialize if full, reset bb to be a new batch
                    end
                    show(bb); println();
                    serialize(bb)  # write new batch to disk
                end
            end

            # RandomAccessBlobs
            b = blob!(B)
            b["msg"] = "HELLO"
            serialize(B)

            nothing
        end

        ## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
        let
            # BlobBatches
            _bb = B[1]
            _bb2 = B[_bb.uuid]
            @test _bb.uuid == _bb2.uuid
            _b = _bb[1]
            _j_b1 = _b["EP.v1", "j"] # return value directly
            _j_b2 = _b[["EP.v1"]]["j"] # returns blob's frame (a Dict) + index
            _j_bb = _bb[["EP.v1"]][_b.uuid]["j"] # returns batch frame (a Dict) + get blob's frame (a Dict) + index
            @test _j_b1 == _j_bb
            @test _j_b2 == _j_bb

            # Random Access Blobs
            @test B[]["msg"] == "HELLO" # return value from default rablob
            @test B["0"]["msg"] == "HELLO" # random blob is called "0"

            # empty!
            B = Bloberia(B_ROOT)
            @test B[]["msg"] == "HELLO" # return value from default rablob
            
            nothing
        end
    end

end
