_pidfile(B::Bloberia) = joinpath(B.root, "B.pidfile")
_getlock(B::Bloberia) = get!(() -> SimpleLockFile(_pidfile(B)), B.temp, "_lock")
_setlock!(B::Bloberia, lk) = setindex!(B["temp"], lk, "_lock")

import Base.lock
Base.lock(f::Function, B::Bloberia; kwargs...) = _lock(f, B; kwargs...)
Base.lock(B::Bloberia; kwargs...) = _lock(B; kwargs...) 

import Base.islocked
Base.islocked(B::Bloberia) = _islocked(B) 

import Base.unlock
Base.unlock(B::Bloberia; force = false) = _unlock(B; force) 
    
function unlock_batches(B::Bloberia; force = true)
    for bb in B
        unlock(bb; force)
    end
end