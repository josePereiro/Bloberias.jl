@time begin
    using ContextFrames
end

## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
# "La Bloberia"
# A way to store on disk the state of an script...
# 

## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
# INPUT
let
    B = Bloberia()
    bb = BlobBatch(B) # load Head frame
    for i in 1:10
        b = Blob(bb) # create a new blob
        b["i"] = i # add field "A" to "0" lite frame
        b["kaka"] = Dict() # add field "kaka" to "0" (default) non-lite frame
        b["EP.v1", "epm"] = Dict() # add field "epm" to "EP.v1" non-lite frame
        b["EP.v1", "r"] = rand() # add field "r" to "EP.v1" lite frame
        commmit!(b)   # push! b into bb, create new frames if necessary
    end
    serialize(bb)  # write new frame to disk
end

## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
# OUTPUT
let
    B = Bloberia()
    for bb in B # iterate fot all BlobBatches
        for bid in bb # load bb's ids.jls frame and iterate it
            b = Blob(bb, bid) # get Blob named bid
            @show b["i"] # get "i" from "0" (default) lite frame (load frame if required)
            @show b["kaka"] # get "kaka" from "0" (default) non-lite frame (load frame if required)
            @show b["EP.v1", "epm"] # get "epm" from "EP.v1" non-lite frame (load frame if required)
            @show b["EP.v1", "r"] # get "epm" from "EP.v1" lite frame (load frame if required)
            b["FVA.v1", "lb"] = rand(10) # add field "lb" to "FBA.v1" lite frame
            commmit!(b)  # update! bb, create new frames if necessary
        end
    end
    # TODO: only write if necessary
    serialize(bb)  # write new frame to disk
end


## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
_glob = 2
_glob2 = Dict()
let
    b = Bloberia()
    # b.dat
    # blobgroup!(b, "kk")
    b["A"] = 1
    b[]
    # b.blob[]
    
    A = 1
    
    merge!(b, @litescope())

    # commit!(b)

    b
end