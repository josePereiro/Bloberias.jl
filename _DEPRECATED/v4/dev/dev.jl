## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
@time begin
    using Bloberias
end

## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
# "La Bloberia"
# A way to store on disk the state of an script...

## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
B_ROOT = joinpath(@__DIR__, "db")
rm(B_ROOT; force = true, recursive = true)
atexit(() -> rm(B_ROOT; force = true, recursive = true)) 
nothing

## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
# lock test
let
    B = Bloberia(B_ROOT)
    rm(B.root; force = true, recursive = true)
    bb = blobbatch!(B)
    rb = blob!(B)
    vb = blob!(bb)

    _bos = [B, bb, rb, vb]
    _dt = 1
    @show _dt
    # no lock
    _t = @elapsed @sync for bo in _bos
        @async sleep(_dt)
    end
    @show _t
    @assert _t < length(_bos) * _dt

    # per object lock
    # effectively no lock
    _t = @elapsed @sync for bo in _bos
        @async lock(bo) do
            @assert true
            sleep(_dt)
        end
    end
    @show _t
    @assert _t < length(_bos) * _dt

    # same lock
    _t = @elapsed @sync for bo in _bos
        B = bloberia(bo)
        @async lock(B) do
            @assert true
            sleep(_dt)
        end
    end
    @show _t
    @assert _t >= length(_bos) * _dt

end

## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
let
    B = Bloberia(B_ROOT)
    rm(B.root; force = true, recursive = true)
    
    # Bloberia
    bref = blobyref(B)
    @assert bref[].root == B.root
    @assert bloberia(bref).root == B.root
    
    # BlobBatch
    bb = blobbatch!(B)
    bref = blobyref(bb)
    @assert bloberia(bref).root == B.root
    @assert bref[].uuid == bb.uuid
    @assert blobbatch(bref).uuid == bb.uuid
    
    # btBatch
    tb = blob!(bb)
    bref = blobyref(tb)
    @assert bloberia(bref).root == B.root
    @assert blobbatch(bref).uuid == bb.uuid
    @assert bref[].uuid == tb.uuid
    @assert blob(bref).uuid == tb.uuid
    
    # btBatchVal
    tb["val"] = 1
    serialize(tb)
    @assert bloberia(bref).root == B.root
    @assert blobbatch(bref).uuid == bb.uuid
    @assert blob(bref).uuid == tb.uuid
    bref = blobyref(tb, "val")
    @assert bref[] == tb["val"]
    
    # raBatch
    rb = blob!(B)
    bref = blobyref(rb)
    @assert bloberia(bref).root == B.root
    @assert bref[].id == rb.id
    @assert blob(bref).id == rb.id
    
    # raBatchVal
    rb["val"] = 1
    serialize(rb)
    @assert bloberia(bref).root == B.root
    @assert blob(bref).id == rb.id
    bref = blobyref(rb, "val")
    @assert bref[] == rb["val"]
    
    nothing
end


## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
# dev
let
    global B = Bloberia(B_ROOT)
    rm(B.root; force = true, recursive = true)
    bb = blobbatch!(B)
    rb = blob!(B)
    vb = blob!(bb)
    
    _dat0 = [1,2,3]
    frame = string(hash(_dat0))
    for b in [rb, vb]
        withblob!(b, :get!, frame, "+1") do
            return _dat0 .+ 1
        end
        @assert b[frame, "+1"] == _dat0 .+ 1
        serialize(b)
    end

    # check again but loaded
    empty!(rb)
    @assert isempty(rb.frames)
    _dat1 = withblob!(rb, :get!, frame, "+1") do
        return "not to load"
    end
    @assert _dat1 == _dat0 .+ 1
    
    empty!(bb)
    @assert isempty(bb.frames)
    vb = blob(bb, 1) # first blob
    _dat1 = withblob!(vb, :get!, frame, "+1") do
        return "not to load"
    end
    @assert _dat1 == _dat0 .+ 1

    B
end

## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
# blobbatches interface
let
    global B = Bloberia(B_ROOT)
    rm(B.root; force = true, recursive = true)
    
    global bb0 = headbatch!(B)
    bb_lim = 100
    setmeta!(B, "batches.blobs.lim", bb_lim)

    # write to ram
    _token = rand()
    for it in 1:(bb_lim ÷ 2)
        b = blob!(bb0)
        b["it"] = it # default frame 0
        b["1", "_token"] = _token # custom frame 0
        isfullbatch(bb0) && break
    end
    @assert !isfullbatch(bb0)
    @assert hasframe(bb0, "1")
    serialize(bb0)
    
    _bbs = collect(eachbatch(B))
    @assert length(_bbs) == 1
    
    bb1 = headbatch!(B) # new non full batch
    @assert hasframe(bb1, "1")
    @assert bb0.uuid == bb1.uuid
    @assert length(bb0) == length(bb1)
    
    bb2 = blobbatch!(B) # new batch
    @assert length(bb2) == 0
    @assert bb0.uuid != bb2.uuid
    @assert length(bb2) != length(bb1)

    # write more
    for it in 1:(bb_lim * 10)
        b = blob!(bb0)
        b["it"] = it # deault frame
        isfullbatch(bb0) && break
    end
    @assert isfullbatch(bb0)
    serialize(bb0)

    bb3 = headbatch!(B)
    @assert length(bb3) == 0
    @assert bb0.uuid != bb3.uuid
    @assert length(bb0) != length(bb3)
end
    
## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
# meta interface
let
    B = Bloberia(B_ROOT)
    rm(B.root; force = true, recursive = true)
    bb = blobbatch!(B)
    
    for obj in [B, bb]
        println(typeof(obj))
        
        mfile = meta_framepath(obj)
        @assert !isfile(mfile)
        
        meta0 = getmeta(obj)
        _dat0 = rand(10)
        setmeta!(obj, "bla", _dat0)
        @assert !isfile(mfile)
        @assert all(meta0["bla"] .== getmeta(obj, "bla"))

        empty!(getmeta(obj))
        meta1 = getmeta(obj)
        @assert isempty(meta1) # no disk copy yet

        
        setmeta!(obj, "bla", _dat0)
        serialize(obj; ignoreempty = false) # create disk copy
        empty!(getmeta(obj))
        @assert all(getmeta(obj, "bla") .== _dat0) # data is loaded on demand
    end

end

## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
# raBlobs
let
    global B = Bloberia(B_ROOT)
    rm(B.root; force = true, recursive = true)

    rb = blob!(B, "globals")
    rb["bla"] = rand(5,5)
    serialize(rb)
    
    rb2 = blob(B, "globals")
    @assert all(rb["bla"] .== rb2["bla"])
end

## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
# blobbatch meta
let
    global B = Bloberia(B_ROOT)
    rm(B.root; force = true, recursive = true)

    # create batch
    bb = blobbatch!(B)
    bb
end




## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
# INPUT
let;
    global B = Bloberia(B_ROOT)
    rm(B.root; force = true, recursive = true)
    # BlobBatches
    for bbi in 1:10
        bb = blobbatch!(B, "global")
        lock(bb)
        N = Int(1e2)
        for i in 1:N
            b = blob!(bb) # create a new blob linked to bb
            b["i"] = rand([i, "A"]) # add field 'j' to default frame '0'
            b["EP.v1", "epm"] = Dict("B" => 2) # add field 'epm' to custom frame 'EP.v1'
            b["EP.v1", "j"] = i*i # add field 'j' to custom frame 'EP.v1'
            merge!(b, @litescope()) # this will overwrite "i"
            # rollserialize!(bb, 100) # serialize if full, reset bb to be a new batch
        end
        serialize(bb)  # write new batch to disk
        show(bb); println();
        unlock(bb)
    end
      
    # RandomAccessBlobs
    b = blob!(B)
    b["msg"] = "HELLO"
    serialize(B)

    nothing
end

## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
let
    global B

    # BlobBatches
    _bb = B[1]
    _bb2 = B[_bb.uuid]
    @assert _bb.uuid == _bb2.uuid
    _b = _bb[1]
    _j_b1 = _b["EP.v1", "j"] # return value directly
    _j_b2 = _b[["EP.v1"]]["j"] # returns blob's frame (a Dict) + index
    _j_bb = _bb[["EP.v1"]][_b.uuid]["j"] # returns batch frame (a Dict) + get blob's frame (a Dict) + index
    @assert _j_b1 == _j_bb
    @assert _j_b2 == _j_bb

    # Random Access Blobs
    @assert B[]["msg"] == "HELLO" # return value from default rablob
    @assert B["0"]["msg"] == "HELLO" # random blob is called "0"
    
    # empty!
    B = Bloberia(B_ROOT)
    @assert B[]["msg"] == "HELLO" # return value from default rablob
    
    nothing
end


## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
# ITERATIVE ACCESS
let
    c = 0
    for bb in B
        global f0 = getframe(bb, "0")
        islocked(bb) && continue # ignore locked
        # @show ep_frame
        # @show bb.meta
        # @show bb.lite
        for uuid in bb # load bb's ids.jls frame and iterate it
            c += 1
            # @show uuid
            b = blob(bb, uuid) # get Blob named bid
            @show b
            b["i"] # get "i" from "0" (default) lite frame (load frame if required (?))
        end
    end
    @show c
    # TODO: only write if necessary
    # serialize(bb)  # write new frame to disk
    nothing
end

## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
# TREE LIKE SHIT
let

end


## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
# TODO: collect(bbs, "EP.v1" => ["epm"]) # collect 'epm; in "EP.v1" frame
# TODO: collect(bb) # load all frames (?)

## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
using Base.Threads
using BenchmarkTools

function _spawn_countfun(bbs)
    count = 0
    for bb in bbs
        count += blobcount(bb)
    end
    return count
end

## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
@time let
    B = Bloberia(joinpath(@__DIR__, "db"))
    bbs = batches(B, "global"; preload = ["0", "EP.v1"])
    for bb in bbs
        show(bb); println()
    end
end

## .-- . -. - .--..- -- .- - --..-.-.- .- -.--

# ## .-- . -. - .--..- -- .- - --..-.-.- .- -.--
# let
#     N = Int(1e8)
#     dat_pool = IdDict()
#     @threads for it in 1:N
#         tid = get!(() -> rand(UInt128), task_local_storage(), :id)
#         get!(dat_pool, tid, 0)
#         dat_pool[tid] += 1
#     end
#     sum(values(dat_pool))
# end
