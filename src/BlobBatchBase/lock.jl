_pidfile(bb::BlobBatches) = joinpath(batchpath(bb), "bb.pidfile")
_getlock(bb::BlobBatches) = get!(() -> SimpleLockFile(_pidfile(bb)), bb.temp, "_lock")
_setlock!(bb::BlobBatches, lk) = setindex!(bb["temp"], lk, "_lock")

import Base.lock
Base.lock(f::Function, bb::BlobBatches; kwargs...) = _lock(f, bb; kwargs...)
Base.lock(bb::BlobBatches; kwargs...) = _lock(bb; kwargs...) 

import Base.islocked
Base.islocked(bb::BlobBatches) = _islocked(bb) 

import Base.unlock
Base.unlock(bb::BlobBatches; force = false) = _unlock(bb; force) 
    