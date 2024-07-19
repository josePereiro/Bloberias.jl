@time begin
    using ContextFrames
end

## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
# "La Bloberia"
# A way to store on disk the state of an script...

## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
# INPUT
let
    global B = Bloberia(joinpath(@__DIR__, "db"))
    # rm(B.root; force = true, recursive = true)
    # TODO: see way this is not working 
    # TODO: Just run this and see why count = 500
    global bb = headbatch(B, "global") # load non full batch or create a new one
    @show bb.uuid
    @show length(bb.uuids)
    for i in 1:500
        global b = blob(bb) # create a new blob
        b["i"] = i # add field 'i' to default frame '0'
        b["bla", "kaka"] = Dict("A" => 1) # add field 'kaka' to custom frame 'bla'
        b["EP.v1", "epm"] = Dict("B" => 2) # add field 'kaka' to custom frame 'bla'
        b["EP.v1", "r"] = rand() # add field "r" to "EP.v1" lite frame
        commmit(b) # push! b into bb, create new frames if necessary
        rollserialize!(bb) # serialize if full, reset bb to be a new batch
    end
    @show length(bb.uuids)
    # @show bb.meta["blobs.count"]
    serialize(bb)  # write new batch to disk
    nothing
end

## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
# OUTPUT
let
    B = Bloberia(joinpath(@__DIR__, "db"))
    foreach_batch(B) do _bb
        global bb = _bb
        uuids = getframe(bb, "uuids")
        ep_frame = getframe(bb, "EP.v1")
        # @show ep_frame
        # @show bb.meta
        # @show bb.lite
        # for b in bb # load bb's ids.jls frame and iterate it
        #     @show b["i"] # get "i" from "0" (default) lite frame (load frame if required (?))
        #     @show b["kaka"] # get "kaka" from "0" (default) non-lite frame (load frame if required (?))
        #     @show b["EP.v1", "epm"] # get "epm" from "EP.v1" non-lite frame (load frame if required (?))
        #     @show b["EP.v1", "r"] # get "epm" from "EP.v1" lite frame (load frame if required (?))
        #     b["FVA.v1", "lb"] = rand(10) # add field "lb" to "FBA.v1" lite frame
        #     # commmit!(b)  # update! bb, create new frames if necessary
        # end
    end
    # TODO: only write if necessary
    # serialize(bb)  # write new frame to disk
    nothing
end

## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
let
    B = Bloberia()
    bbs = eachbatch(B, "global") # iterator per 'global' batches
    # collect(bbs, "EP.v1", "epm") # collect all epm's found at 
end
## .-- . -. - .--..- -- .- - --..-.-.- .- -.--

