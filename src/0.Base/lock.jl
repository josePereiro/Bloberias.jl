# this just requere to implement a _getlock

function _lock(f::Function, obj; kwargs...) 
    lk = _getlock(obj)
    isnothing(lk) && return f() # ignore locking
    lock(f, lk; kwargs...)
end
function _lock(obj; kwargs...) 
    lk = _getlock(obj)
    isnothing(lk) && return # ignore locking 
    lock(lk; kwargs...)
    return obj
end

function _islocked(obj) 
    lk = _getlock(obj)
    isnothing(lk) && return false
    return islocked(lk)
end

function _unlock(obj; force = false) 
    lk = _getlock(obj)
    isnothing(lk) && return # ignore
    return unlock(lk; force)
end