# this just requere to implement a _getlock

function _lock(f::Function, B::Bloberia; kwargs...) 
    lk = _getlock(B)
    isnothing(lk) && return f() # ignore locking
    lock(f, lk, kwargs...)
end
function _lock(B::Bloberia; kwargs...) 
    lk = _getlock(B)
    isnothing(lk) && return # ignore locking 
    lock(lk, kwargs...)
    return B
end

function _islocked(B::Bloberia) 
    lk = _getlock(B)
    isnothing(lk) && return false
    return islocked(lk)
end

function _unlock(B::Bloberia; force = false) 
    lk = _getlock(B)
    isnothing(lk) && return # ignore
    return unlock(lk; force)
end