_pidfile(rb::raBlob) = joinpath(rablobpath(rb), "rb.pidfile")
_getlock(rb::raBlob) = get!(() -> SimpleLockFile(_pidfile(rb)), rb.temp, "_lock")
_setlock!(rb::raBlob, lk) = setindex!(rb["temp"], lk, "_lock")

import Base.lock
Base.lock(f::Function, rb::raBlob; kwargs...) = _lock(f, rb; kwargs...)
Base.lock(rb::raBlob; kwargs...) = _lock(rb; kwargs...) 

import Base.islocked
Base.islocked(rb::raBlob) = _islocked(rb) 

import Base.unlock
Base.unlock(rb::raBlob; force = false) = _unlock(rb; force) 