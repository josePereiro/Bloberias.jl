# -. -- .- ---- - .-. - - .-- . -..... --- -- - .
# To Implement
# A hash for distinguising the object
# It should not change if the object is modified while lk. 
function _lock_obj_identity_hash(obj, h0)::UInt64
    error("Non implemented!!!")
end

# -. -- .- ---- - .-. - - .-- . -..... --- -- - .
# A hash of a collection
function _col_hash(col, h = 0)
    h = hash(h)
    for el in col
        h = hash(el, h)
    end
    return h
end

function _pidfile_path(bo::BlobyObj, args...; B = bloberia(bo))
    root = bloberiapath(B)
    _hash = _lock_obj_identity_hash(bo, UInt(0)) 
    if !isempty(args)
        _hash = _col_hash(args, _hash) # custom extra args...
    end
    _name = string(typeof(bo), ".", repr(_hash), ".pidfile")
    return joinpath(root, "_locks", _name)
end

function getlockfile(bo::BlobyObj, args...) 
    B = bloberia(bo)
    # filepath
    _file = _pidfile_path(bo, args...; B)
    get!(B.temp, _file) do
        return SimpleLockFile(_file)
    end
end

import Base.lock
function Base.lock(f::Function, bo::BlobyObj, args...; kwargs...) 

    lk = getlockfile(bo, args...)
    return lock(f, lk; kwargs...)
end

function Base.lock(bo::BlobyObj, args...; kwargs...) 
    lk = getlockfile(bo, args...)
    return lock(lk; kwargs...)
end

import Base.islocked
function Base.islocked(bo::BlobyObj, args...) 
    lk = getlockfile(bo, args...)
    isnothing(lk) && return false
    return islocked(lk)
end

import Base.unlock
function Base.unlock(bo::BlobyObj, args...; force = false) 
    lk = getlockfile(bo, args...)
    isnothing(lk) && return # ignore
    return unlock(lk; force)
end


function __dolock(f::Function, bo::BlobyObj, lkflag::Bool, args...; kwargs...)
    lkflag ? lock(f, bo, args...; kwargs...) : f()
end