_pidfile(bb::BlobBatch) = joinpath(batchpath(bb), "bb.pidfile")
_getlock(bb::BlobBatch) = get!(() -> SimpleLockFile(_pidfile(bb)), bb.temp, "_lock")
_setlock!(bb::BlobBatch, lk) = setindex!(bb["temp"], lk, "_lock")

import Base.lock
Base.lock(f::Function, bb::BlobBatch; kwargs...) = _lock(f, bb; kwargs...)
Base.lock(bb::BlobBatch; kwargs...) = _lock(bb; kwargs...) 

import Base.islocked
Base.islocked(bb::BlobBatch) = _islocked(bb) 

import Base.unlock
Base.unlock(bb::BlobBatch; force = false) = _unlock(bb; force) 